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

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "LQG_NoiseCharacterization.h"
#include "PMSMBoard.h"
#include "PRBSData.h"
#include "DMA_Transfer.h"
#include "PMSM.h"
#include <dsp.h>
#include <qei32.h>
#include <xc.h>


#ifdef LQG_NOISE

enum {
	CW,
	CCW
};

float Counts2RadSec(int16_t speed);

static float u = 0;
static float Ts = .0003333;

static float x_hat[3][1] = {
	{0},
	{0},
	{0},
};

static float x_dummy[3][1] = {
	{0},
	{0},
	{0},
};

static float K_reg[3][3] = {
	{0.7639, -0.358, -0.5243},
	{0.2752, -0.1471, -0.55},
	{-0.2592, 0.4365, 0.6546},
};

static float L[3][1] = {
	{.0002849},
	{-.00008373},
	{-.001217},
};

static float K[1][3] = {
	{-0.4137, -0.6805, 0.744}
};

void TrapUpdate(uint16_t torque, uint16_t direction);
float RandomInput(void);

/**                          Public Functions                                **/


uint16_t counter = 0;
uint16_t counter2 = 0;

void NoiseInputStep(void)
{
	static float speed;
	uint16_t size = 0;
	static uint8_t out[56];
	qeiCounter w;
	w.l = 0;
	int16_t indexCount = 0;

	if (counter2 < 51) {

		if (GetState(counter)) {
			speed = 250;
		} else {
			speed = 0;
		}

		counter++;
		if (counter == 65535) {
			counter = 0;
			counter2++;
		}

		indexCount = (int) Read32bitQEI1IndexCounter();
		Write32bitQEI1IndexCounter(&w);

		float theta_dot = Counts2RadSec(indexCount) - speed;

		x_dummy[0][0] = (x_hat[0][0] * K_reg[0][0]) + (x_hat[1][0] * K_reg[0][1]) + (x_hat[2][0] * K_reg[0][2]) + (L[0][0] * theta_dot);
		x_dummy[1][0] = (x_hat[1][0] * K_reg[1][0]) + (x_hat[1][0] * K_reg[1][1]) + (x_hat[2][0] * K_reg[1][2]) + (L[1][0] * theta_dot);
		x_dummy[2][0] = (x_hat[2][0] * K_reg[2][0]) + (x_hat[1][0] * K_reg[2][1]) + (x_hat[2][0] * K_reg[2][2]) + (L[2][0] * theta_dot);

		x_hat[0][0] = x_dummy[0][0];
		x_hat[1][0] = x_dummy[1][0];
		x_hat[2][0] = x_dummy[2][0];

		u = -1 * ((K[0][0] * x_hat[0][0]) + (K[0][1] * x_hat[1][0]) + (K[0][2] * x_hat[2][0]));


		size = sprintf((char *) out, "%i,%i,%i\r\n", indexCount, (int16_t) (u * 1750), (int16_t) speed);
		DMA0_UART2_Transfer(size, out);

		//What's the proper case to handle u = 0?!
		if (u < 0) {
			TrapUpdate((uint16_t) (-1 * u * 1750), CCW);
		} else if (u >= 0) {
			TrapUpdate((uint16_t) (u * 1750), CW);
		}

	} else {
		u = 0;
	}

	size = sprintf((char *) out, "%i,%i,%i\r\n", indexCount, (int16_t) (u * 1750), (int16_t) speed);
	DMA0_UART2_Transfer(size, out);

	LED4 ^= 1;
}

float Counts2RadSec(int16_t speed)
{
	return(((speed / (512.0)) * 2 * PI) / Ts);
}

static char seeded = 0;

float RandomInput(void)
{
	float e;
	static float rk1 = 0;
	static float rk2 = 0;
	if (!seeded) {
		srand(TMR5);
		seeded = 1;
		return(0);
	}

	e = ((float) rand() / (float) RAND_MAX);

	e -= .5;

	//LPF
	rk1 = .1 * e + .9 * rk2;
	rk2 = rk1;

	return(rk1);
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
	if (torque > 1750) {
		torque = 1750;
	}

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
	if (u < 0) {
		TrapUpdate((uint16_t) (-1 * u * 1750), CCW);
	} else if (u >= 0) {
		TrapUpdate((uint16_t) (u * 1750), CW);
	}
	IFS1bits.CNIF = 0; // Clear CN interrupt
}

void __attribute__((__interrupt__, no_auto_psv)) _QEI1Interrupt(void)

{
	//POS1CNTL = 0;
	//POS1CNTH = 0;
	IFS3bits.QEI1IF = 0; /* Clear QEI interrupt flag */
}
#endif
