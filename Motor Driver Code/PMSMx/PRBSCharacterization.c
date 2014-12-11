/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Pavlo Milo Manovi
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 * @file	BasicMotorControl.c
 * @author 	Pavlo Manovi
 * @date	March 21st, 2014
 * @brief 	This library provides implementation of control methods for the DRV8301.
 *
 * This library provides implementation of basic trapezoidal control for a BLDC motor.
 *
 */


#ifdef CHARACTERIZE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "PRBSCharacterization.h"
#include "PRBSData.h"
#include "PMSMBoard.h"
#include "DMA_Transfer.h"
#include "PMSM.h"
#include <qei32.h>
#include <xc.h>

static uint32_t timerCurr;
static uint32_t timer;
static uint16_t commandedTorque;
static uint16_t commanded;
static uint8_t changeState;
static uint8_t currentState;
static uint8_t lastState = 0;

static BasicMotorControlInfo motorInfo;

void TrapUpdate(uint16_t torque, uint16_t direction);

char NaN[] = "NaN\r\n";

uint16_t counter = 0;
uint16_t counter2 = 0;

void CharacterizeStep(void)
{
	static uint8_t out[56];
	static uint8_t out1[56];

	TrapUpdate(commandedTorque, CCW);

	if (counter2 < 51) {
		uint16_t size = 0;
		qeiCounter w;
		w.l = 0;
		int16_t indexCount = 0;

		indexCount = (int) Read32bitQEI1IndexCounter();
		Write32bitQEI1IndexCounter(&w);

		if (GetState(counter)) {
			commandedTorque = 873;
			size = sprintf((char *) out, ".5,%i\r\n", indexCount);
			DMA0_UART2_Transfer(size, out);
		} else {
			commandedTorque = 582;
			size = sprintf((char *) out, ".334,%i\r\n", indexCount);
			DMA0_UART2_Transfer(size, out);
		}



		counter++;
		if (counter == 65535) {
			counter = 0;
			counter2++;
		}
	} else {
		commandedTorque = 0;
	}
}




/**
 * This function should exclusively be called by the change notify interrupt to
 * ensure that all hall events have been recorded and that the time between events
 * is appropriately read.
 *
 * The only other conceivable time that this would be called is if the motor is currently
 * not spinning.
 *
 * TODO: Look into preempting this interrupt and turning off interrupts when adding
 * data to the circular buffers as they are non-reentrant.  Calling this function
 * will break those libraries.
 * @param torque
 * @param direction
 */
void TrapUpdate(uint16_t torque, uint16_t direction)
{
#ifndef QEI
	currentState = ((HALL1 << 2) | (HALL2 << 1) | (HALL3));
	if (currentState != lastState) {
		motorInfo.hallCount++;
		// Reading from 32-bit timer
		timerCurr = TMR2;
		timerCurr |= ((uint32_t) TMR3HLD << 16) & 0xFFFF0000;
		timer += timerCurr;
		// Writing to 32-bit timer
		TMR3HLD = 0; //Write msw to the Type C timer holding register
		TMR2 = 0; //Write lsw to the Type B timer register
		changeState = 1;
	}
	lastState = currentState;
#else
#endif

	if (direction == CW) {
		if ((HALL1 && HALL2 && !HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = 0;
			GH_B_DC = torque;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = torque;
			LED1 = 1;
			LED2 = 1;
			LED3 = 0;
		} else if ((!HALL1 && HALL2 && !HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = torque;
			GH_B_DC = torque;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = 0;
			LED1 = 0;
			LED2 = 1;
			LED3 = 0;
		} else if ((!HALL1 && HALL2 && HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = torque;
			GH_B_DC = 0;
			GL_B_DC = 0;
			GH_C_DC = torque;
			GL_C_DC = 0;
			LED1 = 0;
			LED2 = 1;
			LED3 = 1;
		} else if ((!HALL1 && !HALL2 && HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = torque;
			GH_C_DC = torque;
			GL_C_DC = 0;
			LED1 = 0;
			LED2 = 0;
			LED3 = 1;
		} else if ((HALL1 && !HALL2 && HALL3)) {
			GH_A_DC = torque;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = torque;
			GH_C_DC = 0;
			GL_C_DC = 0;
			LED1 = 1;
			LED2 = 0;
			LED3 = 1;
		} else if ((HALL1 && !HALL2 && !HALL3)) {
			GH_A_DC = torque;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = torque;
			LED1 = 1;
			LED2 = 0;
			LED3 = 0;
		}
	} else if (direction == CCW) {
		if ((HALL1 && HALL2 && !HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = torque;
			GH_C_DC = torque;
			GL_C_DC = 0;
			LED1 = 1;
			LED2 = 1;
			LED3 = 0;
		} else if ((!HALL1 && HALL2 && !HALL3)) {
			GH_A_DC = torque;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = torque;
			GH_C_DC = 0;
			GL_C_DC = 0;
			LED1 = 0;
			LED2 = 1;
			LED3 = 0;
		} else if ((!HALL1 && HALL2 && HALL3)) {
			GH_A_DC = torque;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = torque;
			LED1 = 0;
			LED2 = 1;
			LED3 = 1;
		} else if ((!HALL1 && !HALL2 && HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = 0;
			GH_B_DC = torque;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = torque;
			LED1 = 0;
			LED2 = 0;
			LED3 = 1;
		} else if ((HALL1 && !HALL2 && HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = torque;
			GH_B_DC = torque;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = 0;
			LED1 = 1;
			LED2 = 0;
			LED3 = 1;
		} else if ((HALL1 && !HALL2 && !HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = torque;
			GH_B_DC = 0;
			GL_B_DC = 0;
			GH_C_DC = torque;
			GL_C_DC = 0;
			LED1 = 1;
			LED2 = 0;
			LED3 = 0;
		}
	}
}

void __attribute__((__interrupt__, no_auto_psv)) _CNInterrupt(void)
{
	TrapUpdate(commandedTorque, CCW);
	IFS1bits.CNIF = 0; // Clear CN interrupt
}

void __attribute__((__interrupt__, no_auto_psv)) _QEI1Interrupt(void)
{
	IFS3bits.QEI1IF = 0; /* Clear QEI interrupt flag */
}
#endif