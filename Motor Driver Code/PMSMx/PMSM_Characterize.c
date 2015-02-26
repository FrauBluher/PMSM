/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Pavlo Milo Manovi
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
 * @file	PMSM.c
 * @author 	Pavlo Manovi
 * @date 	July, 2013
 * @brief 	Provides methods for controlling PMSM motors sinusoidally.
 *
 * This file provides wrapping implementation of torque, position, and air
 * gap flux linkage control for permemant magnet synchronous motors, sinusoidally.
 *
 */

#include "PMSMBoard.h"

#if defined (CHARACTERIZE_POSITION) || defined (CHARACTERIZE_VELOCITY) || defined (CHARACTERIZE_IMPEDANCE)

#include <xc.h>
#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "PMSM_Characterize.h"
#include "DMA_Transfer.h"
#include "cordic.h"
#include <qei32.h>
#include <uart.h>
#include "TrigData.h"
#include "PRBSData.h"
#include "../CAN Testing/canFiles/motor_can.h"

#define TRANS QEI1STATbits.IDXIRQ

#define SQRT_3 1.732050807568877
#define SQRT_3_2 0.86602540378
#define PI 3.141592653589793
#define PWM 4000 //This should be centralized somewhere...

typedef struct {
	float Vr1;
	float Vr2;
	float Vr3;
} InvClarkOut;

typedef struct {
	float Va;
	float Vb;
} InvParkOut;

typedef struct {
	uint8_t sector;
	uint16_t T0;
	uint16_t Ta;
	uint16_t Tb;
	float Va;
	float Vb;
} TimesOut;

static int32_t theta;
static float Iq;
static float Id;

static float u = 0;
static float d_u = 0;
static float y = 0;
static float Ts = .0003333;

static uint8_t flag = 0;
static uint8_t seeded = 0;

static uint32_t counter = 0;
static uint8_t counter2 = 0;

static int32_t indexCount = 0;
static int32_t lastIndexCount = 0;
static int32_t runningPositionCount = 0;

float RandomInput(void);
int modulo(uint32_t a, uint32_t b);
TimesOut SVPWMTimeCalc(InvParkOut pP);
void SpaceVectorModulation(TimesOut sv);
InvClarkOut InverseClarke(InvParkOut pP);
InvParkOut InversePark(float Vd, float Vq, int16_t position);

#ifdef CHARACTERIZE_POSITION
#ifdef SINE

/**
 * @brief Linear Quadradic State Estimation
 *
 * All the state esimates in the Gaussian Estimator are visible here.
 */

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
	{0.156777775816548, 0.147508105419972, -0.442551063971774},
	{1.001719221949396, -0.011682685756188, -0.409391646462891},
	{0.011475190215306, 0.997687141370211, -0.317501056271297}
};

static float L[3][1] = {
	{1.262202786887033},
	{1.339981601858880},
	{1.166491355877717}

};

static float K[1][3] = {
	{-0.844493135120769, -0.230932253514129, 0.299183789152351}
};

/**
 * @brief Sets the commanded position of the motor.
 */
void SetPosition(float pos)
{
	theta = pos;
}

/**
 * @brief calculates PMSM vectors and updates the init'd MotorInfo struct with duty values.
 *
 * This should be called after one is done updating position, field weakening, and torque.
 * Call only once after all three are updated, not after setting each individual parameter.
 */
#define CLOSED_LOOP
//#define SENSITIVITY_ID

void CharacterizeStep(void)
{
	static uint8_t out[56];
	static uint8_t size;

#ifndef CLOSED_LOOP
	if (counter2 < 1) {
		indexCount = Read32bitQEI1PositionCounter();
		int32_t intermediatePosition;
		intermediatePosition = (runningPositionCount + indexCount);

		if (GetState(counter)) {
			//Commutation phase offset
			indexCount += 512; //Phase offset of 90 degrees.

			indexCount = (-indexCount + 2048) % 2048;

			theta = indexCount;

			SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.5, 0, theta)));
			size = sprintf((char *) out, ".5,%li\r\n", intermediatePosition);
			DMA0_UART2_Transfer(size, out);
		} else {
			//Commutation phase offset
			indexCount += -512; //Phase offset of -90 degrees.

			indexCount = (-indexCount + 2048) % 2048;

			theta = indexCount;

			SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.5, 0, theta)));
			size = sprintf((char *) out, "-.5,%li\r\n", intermediatePosition);
			DMA0_UART2_Transfer(size, out);
		}


		counter++;
		if (counter == 65535) {
			counter = 0;
			counter2++;
		}
	} else {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0, 0, theta)));
	}
#else
#ifndef SENSITIVITY_ID
	if (counter2 < 2) {
		indexCount = Read32bitQEI1PositionCounter();
		int32_t intermediatePosition;
		intermediatePosition = (runningPositionCount + indexCount);

		if (GetState(counter)) {
			y = 100 - ((float) (int32_t) (intermediatePosition) * 0.0030679616); //Scaling it back into radians.
			size = sprintf((char *) out, "100,%li\r\n", intermediatePosition);
			DMA0_UART2_Transfer(size, out);
		} else {
			y = -100 - ((float) (int32_t) (intermediatePosition) * 0.0030679616); //Scaling it back into radians.
			size = sprintf((char *) out, "-100,%li\r\n", intermediatePosition);
			DMA0_UART2_Transfer(size, out);
		}

		x_dummy[0][0] = (x_hat[0][0] * K_reg[0][0]) + (x_hat[1][0] * K_reg[0][1]) + (x_hat[2][0] * K_reg[0][2]) + (L[0][0] * y);
		x_dummy[1][0] = (x_hat[1][0] * K_reg[1][0]) + (x_hat[1][0] * K_reg[1][1]) + (x_hat[2][0] * K_reg[1][2]) + (L[1][0] * y);
		x_dummy[2][0] = (x_hat[2][0] * K_reg[2][0]) + (x_hat[1][0] * K_reg[2][1]) + (x_hat[2][0] * K_reg[2][2]) + (L[2][0] * y);

		x_hat[0][0] = x_dummy[0][0];
		x_hat[1][0] = x_dummy[1][0];
		x_hat[2][0] = x_dummy[2][0];

		u = -1 * ((K[0][0] * x_hat[0][0]) + (K[0][1] * x_hat[1][0]) + (K[0][2] * x_hat[2][0]));

		//SATURATION HERE...  IF YOU REALLY NEED MORE JUICE...  UP THIS TO 1 and -1
		if (u > .8) {
			u = .8;
		} else if (u < -.8) {
			u = -.8;
		}

		if (u > 0) {
			//Commutation phase offset
			indexCount += 512; // - rotorOffset; //Phase offset of 90 degrees.
			d_u = u;
		} else {
			indexCount += -512; // - rotorOffset; //Phase offset of 90 degrees.
			d_u = -u;
		}

		indexCount = (-indexCount + 2048) % 2048;

		SpaceVectorModulation(SVPWMTimeCalc(InversePark(d_u, 0, indexCount)));

		counter++;
		if (counter == 65535) {
			counter = 0;
			counter2++;
		}

	} else {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0, 0, theta)));
	}
#else
	/************************Sensitivity Testing**************************/
	indexCount = Read32bitQEI1PositionCounter();
	int32_t intermediatePosition;
	intermediatePosition = (runningPositionCount + indexCount);

	y = 0 - ((float) (int32_t) (intermediatePosition) * 0.0030679616);

	x_dummy[0][0] = (x_hat[0][0] * K_reg[0][0]) + (x_hat[1][0] * K_reg[0][1])
		+ (x_hat[2][0] * K_reg[0][2]) + (L[0][0] * y);
	x_dummy[1][0] = (x_hat[1][0] * K_reg[1][0]) + (x_hat[1][0] * K_reg[1][1])
		+ (x_hat[2][0] * K_reg[1][2]) + (L[1][0] * y);
	x_dummy[2][0] = (x_hat[2][0] * K_reg[2][0]) + (x_hat[1][0] * K_reg[2][1])
		+ (x_hat[2][0] * K_reg[2][2]) + (L[2][0] * y);

	x_hat[0][0] = x_dummy[0][0];
	x_hat[1][0] = x_dummy[1][0];
	x_hat[2][0] = x_dummy[2][0];

	u = -1 * ((K[0][0] * x_hat[0][0]) + (K[0][1] * x_hat[1][0]) + (K[0][2] * x_hat[2][0]));

	//SATURATION HERE...  IF YOU REALLY NEED MORE JUICE...  UP THIS TO 1 and -1
	if (u > .8) {
		u = .8;
	} else if (u < -.8) {
		u = -.8;
	}

	if (u > 0) {
		//Commutation phase offset
		indexCount += 512; // - rotorOffset; //Phase offset of 90 degrees.
		d_u = u;
	} else {
		indexCount += -512; // - rotorOffset; //Phase offset of 90 degrees.
		d_u = -u;
	}

	indexCount = (-indexCount + 2048) % 2048;

	static float rando = 0;
	rando = RandomInput();

	d_u = d_u + rando;

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(d_u, 0, indexCount)));

	size = sprintf((char *) out, "%li, %li, %li\r\n", (int32_t) (d_u * 10000),
		(int32_t) (rando * 10000), intermediatePosition);
	DMA0_UART2_Transfer(size, out);
#endif
#endif
}

/****************************   Private Stuff   *******************************/

int modulo(uint32_t a, uint32_t b)
{
	int r = a % b;
	return r < 0 ? r + b : r;
}

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

	e = ((float) rand() / RAND_MAX);

	e -= .5;

	//e = e/1.2;

	//LPF
	rk1 = .1 * e + .9 * rk2;
	rk2 = rk1;

	return(rk1);
}

void SpaceVectorModulation(TimesOut sv)
{
	switch (sv.sector) {
	case 1:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - .375 * sv.Vb - .649519 * sv.Va)) - 50;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + .375 * sv.Vb - .216506 * sv.Va)) - 50;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 - .375 * sv.Vb + .216506 * sv.Va)) - 50;
		break;
	case 2:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - .433013 * sv.Va)) - 50;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + .75 * sv.Vb)) - 50;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 + .433013 * sv.Va)) - 50;
		break;
	case 3:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - 0.375 * sv.Vb + .216506 * sv.Va)) - 50;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + 0.375 * sv.Vb + .216506 * sv.Va)) - 50;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 - 0.375 * sv.Vb + .649519 * sv.Va)) - 50;
		break;
	default:
		break;
	}
}

InvClarkOut InverseClarke(InvParkOut pP)
{
	InvClarkOut returnVal;
	returnVal.Vr1 = pP.Vb;
	returnVal.Vr2 = -.5 * pP.Vb + SQRT_3_2 * pP.Va;
	returnVal.Vr3 = -.5 * pP.Vb - SQRT_3_2 * pP.Va;
	return(returnVal);
}

InvParkOut InversePark(float Vq, float Vd, int16_t position1)
{
	static int position;
	position = position1;
	static int16_t cos_position;
	InvParkOut returnVal;

	float cosine;
	float sine;

	if (position1 <= 0) {
		position = 2048 + (position1 % 2048);
		cos_position = (2048 + ((position1 + 512) % 2048)) % 2048;
	} else {
		position = position1 % 2048;
		cos_position = (position1 + 512) % 2048;
	}

	cosine = TRIG_DATA[cos_position];
	sine = TRIG_DATA[position];

	returnVal.Va = Vd * cosine - Vq * sine;
	returnVal.Vb = Vd * sine + Vq * cosine;
	return(returnVal);
}

TimesOut SVPWMTimeCalc(InvParkOut pP)
{
	TimesOut t;
	t.sector = ((uint8_t) ((.0029296875 * theta) + 6)) % 3 + 1;

	t.Va = pP.Va;
	t.Vb = pP.Vb;

	return(t);
}

static int32_t lastCheck;
static int32_t currentCheck;

void __attribute__((__interrupt__, no_auto_psv)) _QEI1Interrupt(void)
{
	currentCheck = Read32bitQEI1PositionCounter();
	runningPositionCount += currentCheck;

	qeiCounter w;

	if (currentCheck > 0) {
		w.l = currentCheck - 2048;
	} else {
		w.l = currentCheck + 2048;
	}

	Write32bitQEI1PositionCounter(&w);
	lastCheck = currentCheck;

	IFS3bits.QEI1IF = 0; /* Clear QEI interrupt flag */
}
#endif
#endif

#ifdef CHARACTERIZE_VELOCITY

/**
 * @brief Linear Quadradic State Estimation
 *
 * All the state esimates in the Gaussian Estimator are visible here.
 */

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
	{0.574814093101266, 0.070664372633882, -0.105344349214271},
	{0.308089137336297, -0.593241451822785, -0.234100902061752},
	{-0.263929752213625, 0.666342910498965, 0.038507896962862}
};

static float L[3][1] = {
	{0.003362260852022},
	{0.000052004816562},
	{0.000148610137435}
};

static float K[1][3] = {
	{-0.364711537429540, -0.280489224857517, -0.116867380021493}
};

static int32_t runningPosition2 = 0;

void SetPosition(float pos)
{
	theta = pos;
}

void CharacterizeStep(void)
{
	static uint8_t out[56];
	static uint8_t size;

#define CLOSED_LOOP

#ifndef CLOSED_LOOP
	indexCount = Read32bitQEI1PositionCounter();
	int32_t intermediatePosition;
	int32_t delta;
	intermediatePosition = (runningPositionCount + indexCount);

	delta = intermediatePosition - runningPosition2;

	if (counter2 < 3) {
		if (GetState(counter)) {
			//Commutation phase offset
			indexCount += 512; //Phase offset of 90 degrees.
			indexCount = (-indexCount + 2048) % 2048;
			theta = indexCount;
			SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.8, 0, theta)));
			size = sprintf((char *) out, ".8,%li\r\n", delta);
			DMA0_UART2_Transfer(size, out);
		} else {
			//Commutation phase offset
			indexCount += -512; //Phase offset of -90 degrees.
			indexCount = (-indexCount + 2048) % 2048;
			theta = indexCount;
			SpaceVectorModulation(SVPWMTimeCalc(InversePark(0, 0, theta)));
			size = sprintf((char *) out, "0,%li\r\n", delta);
			DMA0_UART2_Transfer(size, out);
		}

		counter++;
		if (counter == 65535) {
			counter = 0;
			counter2++;
		}

	} else {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0, 0, theta)));
	}

	runningPosition2 = intermediatePosition;
#else
	indexCount = Read32bitQEI1PositionCounter();
	int32_t intermediatePosition;
	int32_t delta;
	intermediatePosition = (runningPositionCount + indexCount);

	delta = intermediatePosition - runningPosition2;

	if (counter2 < 3) {
		if (GetState(counter)) {
			y = 600 - (((float) (int32_t) (delta) * 0.0030679616) * 3000);
		} else {
			y = 0 - (((float) (int32_t) (delta) * 0.0030679616) * 3000);
		}
		runningPosition2 = intermediatePosition;

		x_dummy[0][0] = (x_hat[0][0] * K_reg[0][0]) + (x_hat[1][0] * K_reg[0][1])
			+ (x_hat[2][0] * K_reg[0][2]) + (L[0][0] * y);
		x_dummy[1][0] = (x_hat[1][0] * K_reg[1][0]) + (x_hat[1][0] * K_reg[1][1])
			+ (x_hat[2][0] * K_reg[1][2]) + (L[1][0] * y);
		x_dummy[2][0] = (x_hat[2][0] * K_reg[2][0]) + (x_hat[1][0] * K_reg[2][1])
			+ (x_hat[2][0] * K_reg[2][2]) + (L[2][0] * y);

		x_hat[0][0] = x_dummy[0][0];
		x_hat[1][0] = x_dummy[1][0];
		x_hat[2][0] = x_dummy[2][0];

		u = -1 * ((K[0][0] * x_hat[0][0]) + (K[0][1] * x_hat[1][0]) + (K[0][2] * x_hat[2][0]));

		//SATURATION HERE...  IF YOU REALLY NEED MORE JUICE...  UP THIS TO 1 and -1
		if (u > .8) {
			u = .8;
		} else if (u < -.8) {
			u = -.8;
		}

		if (u > 0) {
			//Commutation phase offset
			indexCount += 512; // - rotorOffset; //Phase offset of 90 degrees.
			d_u = u;
		} else {
			indexCount += -512; // - rotorOffset; //Phase offset of 90 degrees.
			d_u = -u;
		}

		indexCount = (-indexCount + 2048) % 2048;
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(d_u, 0, indexCount)));

		size = sprintf((char *) out, "%li, %li\r\n", (int32_t) (d_u * 1000), delta);
		DMA0_UART2_Transfer(size, out);

		counter++;
		if (counter == 65535) {
			counter = 0;
			counter2++;
		}

	} else {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0, 0, theta)));
	}

#endif
}
#endif

#ifdef CHARACTERIZE_IMPEDANCE

uint8_t goTherePlease = 1;
uint32_t wowMuchCycle = 0;

void CharacterizeStep(void)
{
	int32_t intermediatePosition;

	if (goTherePlease) {
		indexCount = Read32bitQEI1PositionCounter();
		intermediatePosition = (runningPositionCount + indexCount);

		indexCount += 512; //Phase offset of 90 degrees.

		indexCount = (-indexCount + 2048) % 2048;

		theta = indexCount;

		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.8, 0, theta)));

//		Commanded_Current = 80;
		CO(state_Current_Position) = runningPositionCount;

		wowMuchCycle++;
		if (wowMuchCycle > 2300) {
			goTherePlease = 0;
		}

	} else {
		if (counter2 < 4) {
			indexCount = Read32bitQEI1PositionCounter();
			intermediatePosition = (runningPositionCount + indexCount);

			if (!GetState(counter)) {
				//Commutation phase offset
				indexCount += 512; //Phase offset of 90 degrees.

				indexCount = (-indexCount + 2048) % 2048;

				theta = indexCount;

				SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.65, 0, theta)));

//				Commanded_Current = 65;
				CO(state_Current_Position) = runningPositionCount;
			} else {
				//Commutation phase offset
				indexCount += -512; //Phase offset of -90 degrees.

				indexCount = (-indexCount + 2048) % 2048;

				theta = indexCount;

				SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.65, 0, theta)));

//				Commanded_Current = -65;
				CO(state_Current_Position) = runningPositionCount;
			}


			counter++;
			if (counter == 65535) {
				counter = 0;
				counter2++;
			}
		} else {
			indexCount = Read32bitQEI1PositionCounter();
			intermediatePosition = (runningPositionCount + indexCount);
			SpaceVectorModulation(SVPWMTimeCalc(InversePark(0, 0, theta)));
			CO(state_Current_Position) = runningPositionCount;
		}
	}
}
#endif

/**
 * @brief PMSM initialization call. Aligns rotor and sets QEI offset.
 * @param *information a pointer to the MotorInfo struct that will be updated.
 * @return Returns 1 if successful, returns 0 otherwise.
 */
uint8_t PMSM_Init(MotorInfo *information)
{
	static uint32_t theta1;
	uint32_t i;
	uint32_t j;
	qeiCounter w;

	w.l = 0;
	theta1 = 0;

	for (i = 0; i < 2048; i++) {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.4, 0, theta1)));
		for (j = 0; j < 400; j++) {
			Nop();
		}
		theta1 -= 1;
	}

	for (i = 2048; i > 1; i--) {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.4, 0, theta1)));
		for (j = 0; j < 400; j++) {
			Nop();
		}
		theta1 -= 1;
	}

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.7, 0, 0)));
	while (j < 1400000) {
		Nop();
		j++;
	}

	Write32bitQEI1IndexCounter(&w);
	Write32bitQEI1PositionCounter(&w);
	runningPositionCount = 0;

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(0, 0, 0)));

	return(0);
}

/****************************   Private Stuff   *******************************/

int modulo(uint32_t a, uint32_t b)
{
	int r = a % b;
	return r < 0 ? r + b : r;
}

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

	e = ((float) rand() / RAND_MAX);

	e -= .5;

	//e = e/1.2;

	//LPF
	rk1 = .1 * e + .9 * rk2;
	rk2 = rk1;

	return(rk1);
}

void SpaceVectorModulation(TimesOut sv)
{
	switch (sv.sector) {
	case 1:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - .375 * sv.Vb - .649519 * sv.Va)) - 25;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + .375 * sv.Vb - .216506 * sv.Va)) - 25;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 - .375 * sv.Vb + .216506 * sv.Va)) - 25;
		break;
	case 2:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - .433013 * sv.Va)) - 25;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + .75 * sv.Vb)) - 25;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 + .433013 * sv.Va)) - 25;
		break;
	case 3:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - 0.375 * sv.Vb + .216506 * sv.Va)) - 25;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + 0.375 * sv.Vb + .216506 * sv.Va)) - 25;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 - 0.375 * sv.Vb + .649519 * sv.Va)) - 25;
		break;
	default:
		break;
	}
}

InvClarkOut InverseClarke(InvParkOut pP)
{
	InvClarkOut returnVal;
	returnVal.Vr1 = pP.Vb;
	returnVal.Vr2 = -.5 * pP.Vb + SQRT_3_2 * pP.Va;
	returnVal.Vr3 = -.5 * pP.Vb - SQRT_3_2 * pP.Va;
	return(returnVal);
}

InvParkOut InversePark(float Vq, float Vd, int16_t position1)
{
	static int position;
	position = position1;
	static int16_t cos_position;
	InvParkOut returnVal;

	float cosine;
	float sine;

	if (position1 <= 0) {
		position = 2048 + (position1 % 2048);
		cos_position = (2048 + ((position1 + 512) % 2048)) % 2048;
	} else {
		position = position1 % 2048;
		cos_position = (position1 + 512) % 2048;
	}

	cosine = TRIG_DATA[cos_position];
	sine = TRIG_DATA[position];

	returnVal.Va = Vd * cosine - Vq * sine;
	returnVal.Vb = Vd * sine + Vq * cosine;
	return(returnVal);
}

TimesOut SVPWMTimeCalc(InvParkOut pP)
{
	TimesOut t;
	t.sector = ((uint8_t) ((.0029296875 * indexCount) + 6)) % 3 + 1;

	t.Va = pP.Va;
	t.Vb = pP.Vb;

	return(t);
}

static int32_t lastCheck;
static int32_t currentCheck;

void __attribute__((__interrupt__, no_auto_psv)) _QEI1Interrupt(void)
{
	currentCheck = Read32bitQEI1PositionCounter();
	runningPositionCount += currentCheck;

	qeiCounter w;

	if (currentCheck > 0) {
		w.l = currentCheck - 2048;
	} else {
		w.l = currentCheck + 2048;
	}

	Write32bitQEI1PositionCounter(&w);
	lastCheck = currentCheck;

	IFS3bits.QEI1IF = 0; /* Clear QEI interrupt flag */
}
#endif