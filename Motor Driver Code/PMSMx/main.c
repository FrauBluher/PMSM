/*
 * File:   PMSMx.c
 * Author: Pavlo Milo Manovi
 *
 *
 * If being used with the CAN enabled PMSM Board obtained at either pavlo.me or off of
 * http://github.com/FrauBluher/ as of v 1.6 the following pins are reserved on the
 * dsPIC33EP256MC506:
 *
 * THIS NEEDS TO BE UPDATED FOR v1.9
 */

#include <string.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "PMSMBoard.h"
#include "CircularBuffer.h"
#include "DRV8301.h"
#include "DMA_Transfer.h"
#include "PMSM.h"
#include <dsp.h>
#include <uart.h>

#ifndef CHARACTERIZE
#ifndef LQG_NOISE
#include "BasicMotorControl.h"
#endif
#else
#include "PRBSCharacterization.h"
#endif
#ifdef LQG_NOISE
#include "LQG_NoiseCharacterization.h"
#endif

CircularBuffer uartBuffer;
uint8_t uartBuf[64];
CircularBuffer canBuffer;
uint8_t canBuf[64];
CircularBuffer spiBuffer;
uint16_t spiBuf[64];

ADCBuffer ADCBuff;

uint16_t events = 0;
uint16_t faultPrescalar = 0;
uint16_t torque;

enum {
	EVENT_UART_DATA_READY = 0x01,
	EVENT_CAN_RX = 0x02,
	EVENT_SPI_RX = 0x04,
	EVENT_REPORT_FAULT = 0x08,
	EVENT_UPDATE_SPEED = 0x10,
	EVENT_ADC_DATA = 0x20
};

void EventChecker(void);

int main(void)
{
	static uint16_t size;
	static uint8_t out[56];
	CB_Init(&uartBuffer, uartBuf, 32);
	CB_Init(&spiBuffer, (uint8_t *) spiBuf, 128);

	for (torque = 0; torque < 65533; torque++) {
		Nop();
	}
	InitBoard(&ADCBuff, &uartBuffer, &spiBuffer, EventChecker);

	LED1 = 1;
	LED2 = 1;
	LED3 = 1;
	LED4 = 1;

	while (1) {
		if (events & EVENT_UPDATE_SPEED) {
#ifndef CHARACTERIZE
#ifndef LQG_NOISE
#ifndef SINE
			SpeedControlStep(200);
#endif
#endif
#else
			CharacterizeStep();
#endif
#ifdef LQG_NOISE
			NoiseInputStep();
#endif
#ifdef SINE
			SetAirGapFluxLinkage(0);
			SetTorque(.1);
			PMSM_Update();
			LED4 ^= 1;
#endif
			events &= ~EVENT_UPDATE_SPEED;
		}

		if (events & EVENT_UART_DATA_READY) {
			//Build and check sentence here! Woot woooooot.
			events &= ~EVENT_UART_DATA_READY;
		}

		if (events & EVENT_CAN_RX) {
			events &= ~EVENT_CAN_RX;
		}

		if (events & EVENT_SPI_RX) {
			static uint16_t message[32];
			//			uint16_t size;
			//			uint8_t out[56];
			message[0] = 0;
			message[1] = 0;
			message[2] = 0;
			message[3] = 0;
			//			CB_ReadMany(&spiBuffer, message, spiBuffer.dataSize);
			//			size = sprintf((char *) out, "0x%X, 0x%X, 0x%X, 0x%X\r\n", message[0], message[1], message[2], message[3]);
			//			DMA0_UART2_Transfer(size, out);
			events &= ~EVENT_SPI_RX;
		}

		if (events & EVENT_REPORT_FAULT) {
			events &= ~EVENT_REPORT_FAULT;
		}

		if (events & EVENT_ADC_DATA) {
			size = sprintf((char *) out, "%i, %i\r\n",
				ADCBuff.Adc1Data[0], ADCBuff.Adc1Data[1], ADCBuff.Adc1Data[2]
				);
			DMA0_UART2_Transfer(size, out);
			events &= ~EVENT_ADC_DATA;
		}
	}

}

void EventChecker(void)
{
#ifndef CHARACTERIZE
	//Until I can make a nice non-blocking way of checking the drv for faults
	//this will be called approximately every second and will block for 50uS
	//Pushing the DRV to its max SPI Fcy should bring this number down a little.
	if (faultPrescalar > 999) {
		DRV8301_UpdateStatus();
		faultPrescalar = 0;
		torque = 0;
	} else {
		torque++;
		faultPrescalar++;
	}
	if (uartBuffer.dataSize) {

		events |= EVENT_UART_DATA_READY;
	}

	if (canBuffer.dataSize) {
		events |= EVENT_CAN_RX;
	}

	if (spiBuffer.dataSize) {
		//The first bit of SPI is nonsense from the DRV due to it starting up
		//that needs to be handled in the event handler which will process this
		//event.
		events |= EVENT_SPI_RX;
	}

	if (ADCBuff.newData) {
		ADCBuff.newData = 0;
		events |= EVENT_ADC_DATA;
	}
#endif
	events |= EVENT_UPDATE_SPEED;
}