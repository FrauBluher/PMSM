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

#ifndef SINE
#include "PRBSCharacterization.h"
#else
#include "PMSM_Characterize.h"
#endif
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
uint16_t emptyBuf[64] = {};


ADCBuffer ADCBuff;

uint16_t events = 0;
uint16_t faultPrescalar = 0;
uint16_t commutationPrescalar = 0;
uint16_t torque;

enum {
	EVENT_UART_DATA_READY = 0x01,
	EVENT_CAN_RX = 0x02,
	EVENT_SPI_RX = 0x04,
	EVENT_REPORT_FAULT = 0x08,
	EVENT_UPDATE_SPEED = 0x10,
	EVENT_ADC_DATA = 0x20,
	EVENT_QEI_RQ = 0x40
};

void EventChecker(void);
uint16_t ADC_LPF(void);

int main(void)
{
	static uint16_t size;
	static uint8_t out[56];

	for (torque = 0; torque < 65533; torque++) {
		Nop();
	}
	InitBoard(&ADCBuff, &uartBuffer, &spiBuffer, EventChecker);

	CB_Init(&uartBuffer, uartBuf, 32);
	CB_Init(&spiBuffer, (uint8_t *) spiBuf, 128);

	SetPosition(-100);

	LED1 = 1;
	LED2 = 1;
	LED3 = 1;
	LED4 = 1;

	while (1) {
		if (events & EVENT_QEI_RQ) {
			QEIPositionUpdate();
			events &= ~EVENT_QEI_RQ;
		}
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
#ifndef CHARACTERIZE
#ifdef SINE
			SetAirGapFluxLinkage(0);
			SetTorque(.1);
			PMSM_Update();
			LED4 ^= 1;
#endif
#endif
			events &= ~EVENT_UPDATE_SPEED;
		}

		if (events & EVENT_UART_DATA_READY) {
			events &= ~EVENT_UART_DATA_READY;
		}

		if (events & EVENT_CAN_RX) {
			events &= ~EVENT_CAN_RX;
		}

		if (events & EVENT_SPI_RX) {
			static uint8_t message[32];
			uint16_t size;
			uint8_t out[56];
			message[0] = 0xFF;
			message[1] = 0xFF;
			message[2] = 0xFF;
			message[3] = 0xFF;
			message[4] = 0xFF;
			message[5] = 0xFF;
			message[6] = 0xFF;
			message[7] = 0xFF;

			CB_ReadByte(&spiBuffer, &message[0]);
			CB_ReadByte(&spiBuffer, &message[1]);
			CB_ReadByte(&spiBuffer, &message[2]);
			CB_ReadByte(&spiBuffer, &message[3]);
			CB_ReadByte(&spiBuffer, &message[4]);
			CB_ReadByte(&spiBuffer, &message[5]);
			CB_ReadByte(&spiBuffer, &message[6]);
			CB_ReadByte(&spiBuffer, &message[7]);

			CB_Init(&spiBuffer, &spiBuf, 64);

			size = sprintf((char *) out, "0x%X, 0x%X, 0x%X, 0x%X\r\n",
				((message[0] << 8) | message[1]), ((message[2] << 8) | message[3]),
				((message[4] << 8) | message[5]), ((message[6] << 8) | message[7]));
			DMA0_UART2_Transfer(size, out);
			events &= ~EVENT_SPI_RX;
		}

		if (events & EVENT_REPORT_FAULT) {
			events &= ~EVENT_REPORT_FAULT;
		}

		if (events & EVENT_ADC_DATA) {
			size = sprintf((char *) out, "%i, %i\r\n", ADCBuff.Adc1Data[0], ADCBuff.Adc1Data[1]);
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
	if (faultPrescalar > 1000) {
		//DRV8301_UpdateStatus();
		faultPrescalar = 0;
	} else {
		faultPrescalar++;
	}

	if (uartBuffer.dataSize) {
		events |= EVENT_UART_DATA_READY;
	}

	if (canBuffer.dataSize) {
		events |= EVENT_CAN_RX;
	}

	if (spiBuffer.dataSize > 6) {
		//The first bit of SPI is nonsense from the DRV due to it starting up
		//that needs to be handled in the event handler which will process this
		//event.
		//events |= EVENT_SPI_RX;
	}

#endif

#ifdef SINE
	if (ADCBuff.newData) {
		//		ADCBuff.newData = 0;
		//		events |= EVENT_ADC_DATA;
	}

	events |= EVENT_QEI_RQ;
#endif
	if (commutationPrescalar > 4) {
		events |= EVENT_UPDATE_SPEED;
		commutationPrescalar = 0;
	} else {
		commutationPrescalar++;
	}
}

uint16_t ADC_LPF(void)
{
	static float rk1 = 0;
	static float rk2 = 0;
	int i;

	//LPF
	for (i = 0; i < 10; i++) {
		rk1 = .1 * (float) ADCBuff.Adc1Data[i] + .9 * rk2;
		rk2 = rk1;
	}

	return((uint16_t) rk1);
}
