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
 * @brief 	This library provides SVPWM with position control with an LQG
 *
 * This library provides implementation of a 3rd order LQG controller for a PMSM motor with
 * space vector modulated sinusoidal pulse width modulation control of a permenant magnet
 * synchronous motor.
 *
 * The LQG controller has been characterized in closed loop with an ARX model using a noise
 * model to uncorrelate the characterized input from noise.  Supporting MATLAB code can be
 * found in the same repository that this code was found in.
 */


#include <xc.h>
#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "PMSM.h"
#include "PMSMBoard.h"
#include "DMA_Transfer.h"
#include "cordic.h"
#include <qei32.h>
#include <uart.h>

#ifndef CHARACTERIZE
#include "TrigData.h"

#define SQRT_3_2 0.86602540378
#define SQRT_3 1.732050807568877
#define SPOOL_SCALING_FACTOR 565.486683301
#define PULSES_PER_REVOLUTION 223232

#define TRANS QEI1STATbits.IDXIRQ

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

static float theta;
static float Iq;
static float Id;
static float d_u;
static float y;
static float cableVelocity;

static uint8_t flag = 0;
static int32_t rotorOffset2;
static int32_t rotorOffset;

static int32_t indexCount = 0;
static int32_t lastIndexCount = 0;
static int32_t runningPositionCount = 0;
static int32_t lastRunningPostionCount = 0;

/**
 * @brief Linear Quadradic State Estimation
 *
 * All the state esimates in the Gaussian Estimator are visible here.
 */
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
	{-0.4915, 0.7935, 0.2959},
	{-0.1285, 0.3307, -0.8863},
	{-0.0087, 0.0893, 0.4552},
};

static float L[3][1] = {
	{-1.8747},
	{-4.6113},
	{4.1045},
};

static float K[1][3] = {
	{-0.0088, -0.4743, -1.1845}
};

void SpaceVectorModulation(TimesOut sv);
InvClarkOut InverseClarke(InvParkOut pP);
InvParkOut InversePark(float Vd, float Vq, int16_t position);
TimesOut SVPWMTimeCalc(InvParkOut pP);

/**
 * @brief PMSM initialization call. Aligns rotor and sets QEI offset.
 * @param *information a pointer to the MotorInfo struct that will be updated.
 * @return Returns 1 if successful, returns 0 otherwise.
 */
uint8_t PMSM_Init(MotorInfo *information)
{
	static uint16_t size;
	static uint32_t theta1;
	static uint8_t out[56];

	uint32_t i;
	uint32_t j;
	qeiCounter w;
	w.l = 0;

	theta1 = 0;
	for (i = 0; i < 3096; i++) {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.4, 0, theta1)));
		for (j = 0; j < 800; j++) {
			Nop();
		}
		theta1 -= 1;
	}

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.8, 0, 0)));
	for (i = 0; i < 40000; i++) {
		Nop();
	}

	rotorOffset = Read32bitQEI1PositionCounter();

	if (rotorOffset < 0) {
		rotorOffset = 2048 + rotorOffset;
	}


	/**********************************************************************/
	/**********************************************************************/
	/**********************************************************************/

	theta1 = 0;

	for (i = 0; i < 3096; i++) {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.4, 0, theta1)));
		for (j = 0; j < 800; j++) {
			Nop();
		}
		theta1 += 1;
	}

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.8, 0, 0)));
	for (i = 0; i < 40000; i++) {
		Nop();
	}

	rotorOffset2 = Read32bitQEI1PositionCounter();

	if (rotorOffset2 < 0) {
		rotorOffset2 = 2048 + rotorOffset2;
	}

	rotorOffset = (rotorOffset + rotorOffset2) / 2;

	size = sprintf((char *) out, "Rotor Offset: %li\r\n", rotorOffset);
	DMA0_UART2_Transfer(size, (uint8_t *) out);

	return(0);
}

/**
 * @brief Sets the commanded position of the motor.
 */
void SetPosition(float pos)
{
	theta = pos;
}

/**
 * @brief Sets the commanded torque of the motor.
 * @param power Percentage of torque requested from 0 - 100%.
 */
void SetTorque(uint8_t power)
{
	Iq = power;
}

/**
 * @brief Sets the air gap flux linkage value.
 * @param Id Air gap flux linkage timing advance.  ~0 to -2.5.
 */
void SetAirGapFluxLinkage(float id)
{
	Id = id;
}

/**
 * @brief Calculates last known cable length and returns it.
 * @return Cable length in mm.
 */
int32_t GetCableLength(void)
{
	return(runningPositionCount / PULSES_PER_REVOLUTION);
}

/**
 * @brief Returns last known cable velocity in mm/s.
 * @return Cable velocity in mm/S.
 */
int32_t GetCableVelocity(void)
{
	/**
	 * Cable Velocity: ((2 * Pi * Radius of Spool) * Delta_Rotations) / Ts_Period
	 * Radius of Spool: 30 mm
	 * Ts_Period: 333 uS
	 * Delta_Rotations: runningCount - lastCount
	 *
	 * All of these values combine to make SPOOL_SCALING_FACTOR
	 */
	cableVelocity = ((runningPositionCount - lastRunningPostionCount) /
		PULSES_PER_REVOLUTION) / SPOOL_SCALING_FACTOR;

	return((int32_t) cableVelocity);
}

void PMSM_Update(void)
{

	y = theta - ((float) (int32_t) runningPositionCount * 0.0030679616); //Scaling it back into radians.

	x_dummy[0][0] = (x_hat[0][0] * K_reg[0][0]) + (x_hat[1][0] * K_reg[0][1]) + (x_hat[2][0] * K_reg[0][2]) + (L[0][0] * y);
	x_dummy[1][0] = (x_hat[1][0] * K_reg[1][0]) + (x_hat[1][0] * K_reg[1][1]) + (x_hat[2][0] * K_reg[1][2]) + (L[1][0] * y);
	x_dummy[2][0] = (x_hat[2][0] * K_reg[2][0]) + (x_hat[1][0] * K_reg[2][1]) + (x_hat[2][0] * K_reg[2][2]) + (L[2][0] * y);

	x_hat[0][0] = x_dummy[0][0];
	x_hat[1][0] = x_dummy[1][0];
	x_hat[2][0] = x_dummy[2][0];

	u = -1 * ((K[0][0] * x_hat[0][0]) + (K[0][1] * x_hat[1][0]) + (K[0][2] * x_hat[2][0]));

	//SATURATION HERE...  IF YOU REALLY NEED MORE JUICE...  UP THIS TO 1 and -1
	if (u > .7) {
		u = .7;
	} else if (u < -.7) {
		u = -.7;
	}

	if (u > 0) {
		//Commutation phase offset
		indexCount += 512 - rotorOffset; //Phase offset of 90 degrees.
		d_u = u;
	} else {
		indexCount += -512 - rotorOffset; //Phase offset of 90 degrees.
		d_u = -u;
	}

	indexCount = (-indexCount + 2048) % 2048;


	SpaceVectorModulation(SVPWMTimeCalc(InversePark(d_u, 0, indexCount)));
}

/****************************   Private Stuff   *******************************/

void SpaceVectorModulation(TimesOut sv)
{
	switch (sv.sector) {
	case 1:
		GH_A_DC = (uint16_t) PHASE1 * (.5 - .375 * sv.Vb - .649519 * sv.Va);
		GH_B_DC = (uint16_t) PHASE1 * (.5 + .375 * sv.Vb - .216506 * sv.Va);
		GH_C_DC = (uint16_t) PHASE1 * (.5 - .375 * sv.Vb + .216506 * sv.Va);
		break;
	case 2:
		GH_A_DC = (uint16_t) PHASE1 * (.5 - .433013 * sv.Va);
		GH_B_DC = (uint16_t) PHASE1 * (.5 + .75 * sv.Vb);
		GH_C_DC = (uint16_t) PHASE1 * (.5 + .433013 * sv.Va);
		break;
	case 3:
		GH_A_DC = (uint16_t) PHASE1 * (.5 - 0.375 * sv.Vb + .216506 * sv.Va);
		GH_B_DC = (uint16_t) PHASE1 * (.5 + 0.375 * sv.Vb + .216506 * sv.Va);
		GH_C_DC = (uint16_t) PHASE1 * (.5 - 0.375 * sv.Vb + .649519 * sv.Va);
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
	static uint16_t size;
	static uint8_t out[56];

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

void __attribute__((__interrupt__, no_auto_psv)) _QEI1Interrupt(void)
{
	int i;
	flag = 1;

	IFS3bits.QEI1IF = 0; /* Clear QEI interrupt flag */
}

void QEIPositionUpdate(void)
{
	indexCount = Read32bitQEI1PositionCounter();

	if (!flag) {
		lastIndexCount = indexCount;
		flag = 1;
	}

	if (lastIndexCount != indexCount) {
		if (lastIndexCount > 0) {
			if (indexCount > 0) {
				if ((lastIndexCount > indexCount) && TRANS) {
					runningPositionCount += (2048 - lastIndexCount) + indexCount;
				} else if ((lastIndexCount > indexCount) && !TRANS) {
					runningPositionCount -= lastIndexCount - indexCount;
				} else if ((lastIndexCount < indexCount) && !TRANS) {
					runningPositionCount += indexCount - lastIndexCount;
				}
			} else {
				runningPositionCount += indexCount - lastIndexCount;
			}
		} else {
			if (indexCount < 0) {
				if ((lastIndexCount < indexCount) && TRANS) {
					runningPositionCount += -(2048 + lastIndexCount) + indexCount;
				} else if ((lastIndexCount < indexCount) && !TRANS) {
					runningPositionCount += -(lastIndexCount - indexCount);
				} else if ((lastIndexCount > indexCount) && !TRANS) {
					runningPositionCount += indexCount - lastIndexCount;
				}
			} else {
				runningPositionCount -= indexCount - lastIndexCount;
			}
		}
	}
	QEI1STATbits.IDXIRQ = 0;

	lastIndexCount = indexCount;
}
#endif
