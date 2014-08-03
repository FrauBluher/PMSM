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

#ifndef CHARACTERIZE
#include "BasicMotorControl.h"
#else
#include "PRBSCharacterization.h"
#endif

CircularBuffer uartBuffer;
uint8_t uartBuf[64];
CircularBuffer canBuffer;
uint8_t canBuf[64];
CircularBuffer spiBuffer;
uint16_t spiBuf[64];

extern BasicMotorControlInfo motorInfo;

uint16_t events = 0;
uint16_t faultPrescalar = 0;
uint16_t torque;

enum {
	EVENT_UART_DATA_READY = 0x01,
	EVENT_CAN_RX = 0x02,
	EVENT_SPI_RX = 0x04,
	EVENT_REPORT_FAULT = 0x08,
	EVENT_UPDATE_SPEED = 0x10
};

void EventChecker(void);

int main(void)
{
	CB_Init(&uartBuffer, uartBuf, 32);
	CB_Init(&spiBuffer, (uint8_t *) spiBuf, 128);
	InitBoard(&uartBuffer, &spiBuffer, EventChecker);
#ifndef CHARACTERIZE
	SpeedControlInit(3, 3, 0);
#endif

	LED1 = 1;
	LED2 = 1;
	LED3 = 1;
	LED4 = 1;

	while (1) {
		if (events & EVENT_UPDATE_SPEED) {
#ifndef CHARACTERIZE
			SpeedControlStep(9000, CW, 1);
#else
			CharacterizeStep();
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
			//			uint16_t message[32];
			//			uint8_t out[56];
			//			CB_ReadMany(&spiBuffer, message, spiBuffer.dataSize);
			//			sprintf((char *) out, "Speed: %i, 0x%X, 0x%X\r\n", motorInfo.hallCount, message[0], message[1]);
			//			DMA0_UART2_Transfer(strlen((char *) out), out);
			events &= ~EVENT_SPI_RX;
		}

		if (events & EVENT_REPORT_FAULT) {
			events &= ~EVENT_REPORT_FAULT;
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
#endif
	events |= EVENT_UPDATE_SPEED;
}