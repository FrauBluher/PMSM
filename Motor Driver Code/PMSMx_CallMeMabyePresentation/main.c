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

void Note2PTPER(uint32_t note);

ADCBuffer ADCBuff;

uint16_t events = 0;
uint16_t tick = 0;
uint16_t note = 0;
uint16_t i = 0;
uint16_t j = 0;
uint16_t faultPrescalar = 0;
uint16_t torque;

enum {
	A = 3520,
	G = 3135,
	B = 3951,
	D = 2349,
	C = 2093,
	PAUSE = 0
};

int32_t callme[40][40] = {
	{6271, 1000},
	{PAUSE, 150},
	{1975, 1000},
	{PAUSE, 300},
	{2349, 1000},
	{PAUSE, 300},
	{6271, 1000},
	{PAUSE, 100},
	{D, 1000},
	{PAUSE, 150},
	{B, 1000},
	{PAUSE, 150},
	{B, 1000},
	{PAUSE, 575},


	{D, 100},
	{PAUSE, 450},
	{B, 1000},
	{PAUSE, 100},
	{G, 1000},
	{PAUSE, 100},
	{G, 1000},
	{PAUSE, 100},
	{B, 1000},
	{PAUSE, 100},
	{C, 1000},
	{PAUSE, 100},
	{B, 1000},
	{PAUSE, 100},
	{G, 1000},
	{PAUSE, 100},
	{G, 1000},
	{PAUSE, 100},
	{B, 1000},
	{PAUSE, 100},
	{A, 1000},
	{PAUSE, 100},
	{A, 1000},
	{PAUSE, 100},
	{G, 1000},
	{PAUSE, 100},
};

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
	static float runningTotal = 0;
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

	Note2PTPER(G);

	while (1) {
		torque = 1000;
	}
}

void EventChecker(void)
{
	if (note && tick) {
		GH_A_DC = torque;
		GL_A_DC = 0;
		GH_B_DC = 0;
		GL_B_DC = torque;
		GH_C_DC = 0;
		GL_C_DC = 0;
		LED1 = 1;
		LED2 = 0;
		LED3 = 0;
	} else if (note && !tick) {
		GH_A_DC = 0;
		GL_A_DC = 0;
		GH_B_DC = 0;
		GL_B_DC = torque;
		GH_C_DC = torque;
		GL_C_DC = 0;
		LED1 = 1;
		LED2 = 1;
		LED3 = 0;
	} else if (!note) {
		GH_A_DC = 0;
		GL_A_DC = 0;
		GH_B_DC = 0;
		GL_B_DC = 0;
		GH_C_DC = 0;
		GL_C_DC = 0;
		LED1 = 1;
		LED2 = 1;
		LED3 = 1;
	}


	if (i < callme[j][1]) {
		i++;
	} else {
		i = 0;

		if (j > 39) {
			j = 0;
		} else {
			j++;
		}

		if (callme[j][0]) {
			Note2PTPER(callme[j][0]);
		} else {
			note = 0;
		}
	}
	tick ^= 1;
	LED1 ^= 1;
}

void Note2PTPER(uint32_t note1)
{
	note = note1;
	PR7 = (273437 / (note1));
}
