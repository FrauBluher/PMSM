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

#include "../CAN Testing/canFiles/motor_can.h"
#include "../CAN Testing/canFiles/init_motor_control.h"
#if defined (CHARACTERIZE_POSITION) || defined (CHARACTERIZE_VELOCITY) || defined (CHARACTERIZE_IMPEDANCE)
#include "PMSM_Characterize.h"

#else

#ifdef VELOCITY
#include "PMSM_Velocity.h"
#endif

#ifdef POSITION
#include "PMSM_Position.h"
#endif

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
uint16_t faultPrescalar1 = 0;
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

int
main(void)
{
	static uint16_t size;
	static uint8_t out[56];

	uint32_t count = 0;
	float incPos = 0;
	uint8_t i = 1;

	/*Enable interrupts*/
	INTCON2bits.GIE = 1; //disabled by the bootloader, so we must absolutely enable this!!!

	for (torque = 0; torque < 65533; torque++) {
		Nop();
	}
	InitBoard(&ADCBuff, &uartBuffer, &spiBuffer, EventChecker);

	if (can_motor_init()) {
		while (1);
	}
	CB_Init(&uartBuffer, uartBuf, 32);
	CB_Init(&spiBuffer, (uint8_t *) spiBuf, 128);

	LED1 = 1;
	LED2 = 0;
	LED3 = 1;
	LED4 = 1;

#ifdef POSITION
	/* This is used for testing */
	//    	SetPosition(incPos);
#endif

#ifdef VELOCITY
	SetVelocity(600);
#endif

	while (1) {
		if (events & EVENT_UPDATE_SPEED) {
#if defined (CHARACTERIZE_POSITION) || defined (CHARACTERIZE_VELOCITY) || defined (CHARACTERIZE_IMPEDANCE)
			CharacterizeStep();
#else
#ifdef VELOCITY
			//			SetVelocity((float)Target_Velocity);
			PMSM_Update_Velocity();
#endif
#ifdef POSITION
			if (count > 5000) {
				if (i) {
					SetPosition(2000);
					i = 0;
				} else {
					incPos = 0;
					SetPosition(-2000);
					i = 1;
				}
				count = 0;
			}
			count++;
//			SetPosition(200);
			//			SetPosition((float) Target_Position);
			PMSM_Update_Position();
#endif
#endif
			events &= ~EVENT_UPDATE_SPEED;
		}

		if (events & EVENT_CAN) {
			can_process();
			//          LED2 = !LED2;

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

			//Actual_Position = (uint32_t) GetCableLength();
			//Actual_Velocity = (uint32_t) GetCableVelocity();

			can_time_dispatch();
			events &= ~EVENT_CAN;
		}

		if (events & EVENT_UART_DATA_READY) {
			events &= ~EVENT_UART_DATA_READY;
		}

		//		if (events & EVENT_CAN_RX) {
		//			events &= ~EVENT_CAN_RX;
		//		}

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

			//			size = sprintf((char *) out, "0x%X, 0x%X, 0x%X, 0x%X\r\n",
			//				((message[0] << 8) | message[1]), ((message[2] << 8) | message[3]),
			//				((message[4] << 8) | message[5]), ((message[6] << 8) | message[7]));
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

void
EventChecker(void)
{
#if defined (CHARACTERIZE_POSITION) || defined (CHARACTERIZE_VELOCITY)
#else
	//Until I can make a nice non-blocking way of checking the drv for faults
	//this will be called approximately every second and will block for 50uS
	//Pushing the DRV to its max SPI Fcy should bring this number down a little.
	if (faultPrescalar > 15000) {
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

	if (spiBuffer.dataSize > 6) {
		//The first bit of SPI is nonsense from the DRV due to it starting up
		//that needs to be handled in the event handler which will process this
		//event.
		//events |= EVENT_SPI_RX;
	}

	if (canPrescaler > 2) {
		events |= EVENT_CAN;
		canPrescaler = 0;
	} else {
		canPrescaler++;
	}
#endif

#ifdef SINE
	if (ADCBuff.newData) {
		//		ADCBuff.newData = 0;
		//		events |= EVENT_ADC_DATA;
	}
#endif
	// Running at ~930Hz
	if (commutationPrescalar > 15) {
		events |= EVENT_UPDATE_SPEED;
		commutationPrescalar = 0;
	} else {
		commutationPrescalar++;
	}
}

uint16_t
ADC_LPF(void)
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
