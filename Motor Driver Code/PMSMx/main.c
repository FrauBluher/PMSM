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
#include "../../../../../Code/SSB_Code/Motor_Driver/motor_can.h"
#include "../../../../../Code/SSB_Code/Motor_Driver/can_dspic33e_motor.h"

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

uint8_t canPrescaler = 0;
extern can_data can_state;
extern uint8_t txreq_bitarray;

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

	can_state.init_return = RET_UNKNOWN;
	if (can_motor_init()) {
		while (1);
	}

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
	if (canPrescaler > 2) {
		can_process();

		if (txreq_bitarray & 0b00000001 && !C1TR01CONbits.TXREQ0) {
			C1TR01CONbits.TXREQ0 = 1;
			txreq_bitarray = txreq_bitarray & 0b11111110;
		}
		if (txreq_bitarray & 0b00000010 && !C1TR01CONbits.TXREQ1) {
			C1TR01CONbits.TXREQ1 = 1;
			txreq_bitarray = txreq_bitarray & 0b11111101;
		}
		if (txreq_bitarray & 0b00000100 && !C1TR23CONbits.TXREQ2) {
			C1TR23CONbits.TXREQ2 = 1;
			txreq_bitarray = txreq_bitarray & 0b11111011;
		}
		if (txreq_bitarray & 0b00001000 && !C1TR23CONbits.TXREQ3) {
			C1TR23CONbits.TXREQ3 = 1;
			txreq_bitarray = txreq_bitarray & 0b11110111;
		}
		if (txreq_bitarray & 0b00010000 && !C1TR45CONbits.TXREQ4) {
			C1TR45CONbits.TXREQ4 = 1;
			txreq_bitarray = txreq_bitarray & 0b11101111;
		}
		if (txreq_bitarray & 0b00100000 && !C1TR45CONbits.TXREQ5) {
			C1TR45CONbits.TXREQ5 = 1;
			txreq_bitarray = txreq_bitarray & 0b11011111;
		}
		if (txreq_bitarray & 0b01000000 && !C1TR67CONbits.TXREQ6) {
			C1TR67CONbits.TXREQ6 = 1;
			txreq_bitarray = txreq_bitarray & 0b10111111;
		}

		can_time_dispatch();
		canPrescaler = 0;
	} else {
		canPrescaler++;
	}
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