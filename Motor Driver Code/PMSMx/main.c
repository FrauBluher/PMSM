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
#include "../CAN Testing/canFiles/motor_can.h"
#include "../CAN Testing/canFiles/init_motor_control.h"
#include <dsp.h>
#include <uart.h>

#ifndef CHARACTERIZE
#ifndef LQG_NOISE
#include "BasicMotorControl.h"
#include "rtwtypes.h"
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

ADCBuffer ADCBuff;

uint16_t events = 0;
uint16_t faultPrescalar = 0;
uint16_t commutationPrescalar = 0;
uint16_t torque;

uint16_t canPrescaler = 0;
extern uint8_t txreq_bitarray;
uint16_t controlPrescale = 0;

enum {
	EVENT_UART_DATA_READY = 0x01,
	EVENT_CAN = 0x02,
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
	CB_Init(&uartBuffer, uartBuf, 32);
	CB_Init(&spiBuffer, (uint8_t *) spiBuf, 128);

	for (torque = 0; torque < 65533; torque++) {
		Nop();
	}
	InitBoard(&ADCBuff, &uartBuffer, &spiBuffer, EventChecker);

	//	SetPosition(0);

	if (can_motor_init()) {
		while (1);
	}

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
//			SpeedControlStep(200);
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

		if (events & EVENT_CAN) {
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
//			SetPosition((float)Target_position);

			impedance_controller(GetCableLength(), GetCableVelocity());
//			if (controlPrescale > 1) {
//				//			terrible_P_motor_controller(8192000);
//				impedance_controller(GetCableLength(), GetCableVelocity());
//				controlPrescale = 0;
//			}
//			controlPrescale++;
			events &= ~EVENT_CAN;
		}

		if (events & EVENT_UART_DATA_READY) {
			//Build and check sentence here! Woot woooooot.
			events &= ~EVENT_UART_DATA_READY;
		}

//		if (events & EVENT_CAN_RX) {
//			events &= ~EVENT_CAN_RX;
//		}

		if (events & EVENT_SPI_RX) {
			//static uint16_t message[32];
			//			uint16_t size;
			//			uint8_t out[56];
			//			message[0] = 0;
			//			message[1] = 0;
			//			message[2] = 0;
			//			message[3] = 0;
			//			CB_ReadMany(&spiBuffer, message, spiBuffer.dataSize);
			//			size = sprintf((char *) out, "0x%X, 0x%X, 0x%X, 0x%X\r\n", message[0], message[1], message[2], message[3]);
			//			DMA0_UART2_Transfer(size, out);
			events &= ~EVENT_SPI_RX;
		}

		if (events & EVENT_REPORT_FAULT) {
			events &= ~EVENT_REPORT_FAULT;
		}

		if (events & EVENT_ADC_DATA) {
			//			size = sprintf((char *) out, "%i, %i\r\n", ADCBuff.Adc1Data[0], ADCBuff.Adc1Data[1]);
			//			DMA0_UART2_Transfer(size, out);
			events &= ~EVENT_ADC_DATA;
		}
	}
}

void EventChecker(void)
{
#ifndef CHARACTERIZE
	if (canPrescaler > 2) {
		can_time_dispatch();
		events |= EVENT_CAN;
		canPrescaler = 0;
	} else {
		canPrescaler++;
	}
	//Until I can make a nice non-blocking way of checking the drv for faults
	//this will be called approximately every second and will block for 50uS
	//Pushing the DRV to its max SPI Fcy should bring this number down a little.
	if (faultPrescalar > 5999) {
		DRV8301_UpdateStatus();
		faultPrescalar = 0;
	} else {
		faultPrescalar++;
	}

	if (uartBuffer.dataSize) {

		events |= EVENT_UART_DATA_READY;
	}

	//	if (canBuffer.dataSize) {
	//		events |= EVENT_CAN_RX;
	//	}

	if (spiBuffer.dataSize) {
		//The first bit of SPI is nonsense from the DRV due to it starting up
		//that needs to be handled in the event handler which will process this
		//event.
		events |= EVENT_SPI_RX;
	}

#endif

#ifdef SINE
	if (ADCBuff.newData) {
		//		ADCBuff.newData = 0;
		//		events |= EVENT_ADC_DATA;
	}

	events |= EVENT_QEI_RQ;
#endif
	events |= EVENT_QEI_RQ; // ADDED for Speed Control with position sensing

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
