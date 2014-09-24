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
#include "../../../../../Code/SSB_Code/Motor_Driver/motor_can.h"

#ifndef CHARACTERIZE
#include "TrigData.h"

#warning The motor driver code is in alpha.

#define SQRT_3 1.732050807568877
#define SQRT_3_2 0.86602540378
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
static float u1 = 0;
static float u2 = 0;
static float u3 = 0;
static float y = 0;
static float y1 = 0;
static float y2 = 0;
static float y3 = 0;
static float dummy_u = 0;

static float a1 = -.2944;
static float a2 = -.05211;
static float a3 = .06287;
static float a4 = 0;
static float a5 = 0;
static float b1 = -2.649;
static float b2 = 1.381;
static float b3 = .9905;
static float b4 = 0;
static float b5 = 0;

static uint8_t flag = 0;
static uint8_t seeded = 0;
static int32_t rotorOffset2;
static int32_t rotorOffset;

static uint32_t counter = 0;
static uint8_t counter2 = 0;

static int32_t indexCount = 0;
static int32_t lastIndexCount = 0;
static int32_t runningPositionCount = 0;

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
	static uint8_t out[56];

	uint16_t i;
	uint16_t j;
	qeiCounter w;
	w.l = 0;

	theta = 0;
	for (i = 0; i < 3096; i++) {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.05, 0, theta)));
		for (j = 0; j < 400; j++) {
			Nop();
		}
		theta -= 1;
	}

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.1, 0, 0)));
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

	theta = 0;

	for (i = 0; i < 3096; i++) {
		SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.05, 0, theta)));
		for (j = 0; j < 400; j++) {
			Nop();
		}
		theta += 1;
	}

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.1, 0, 0)));
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
 * @param pos The position of the rotor in radians from 0 - 2pi / n-poles.
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
 * @brief calculates PMSM vectors and updates the init'd MotorInfo struct with duty values.
 *
 * This should be called after one is done updating position, field weakening, and torque.
 * Call only once after all three are updated, not after setting each individual parameter.
 */
void PMSM_Update(void)
{
//	indexCount = Read32bitQEI1PositionCounter();
//
//	if (!flag) {
//		lastIndexCount = indexCount;
//		flag = 1;
//	}
//
//	//TODO: Fix QEI Drift...
//	// -- Run event loop faster.
//	// -- Faster outer loop for tracking index count.
//	if (lastIndexCount != indexCount) {
//		if (lastIndexCount > 0) {
//			if (indexCount > 0) {
//				if ((lastIndexCount > indexCount) && TRANS) {
//					runningPositionCount += (2048 - lastIndexCount) + indexCount;
//				} else if ((lastIndexCount > indexCount) && !TRANS) {
//					runningPositionCount -= lastIndexCount - indexCount;
//				} else if ((lastIndexCount < indexCount) && !TRANS) {
//					runningPositionCount += indexCount - lastIndexCount;
//				}
//			} else {
//				runningPositionCount += indexCount - lastIndexCount;
//			}
//		} else {
//			if (indexCount < 0) {
//				if ((lastIndexCount < indexCount) && TRANS) {
//					runningPositionCount += -(2048 + lastIndexCount) + indexCount;
//				} else if ((lastIndexCount < indexCount) && !TRANS) {
//					runningPositionCount += -(lastIndexCount - indexCount);
//				} else if ((lastIndexCount > indexCount) && !TRANS) {
//					runningPositionCount += indexCount - lastIndexCount;
//				}
//			} else {
//				runningPositionCount -= indexCount - lastIndexCount;
//			}
//		}
//	}
//	QEI1STATbits.IDXIRQ = 0;
//
//	lastIndexCount = indexCount;
//	y3 = y2;
//	y2 = y1;
//	y1 = y;
//
//	y = pos - ((float) (int32_t) runningPositionCount * 0.0030679616); //Scaling it back into radians.
//	u = b1 * y + b2 * y1 + b3 * y2 + b4 * y3 - a1 * u - a2 * u1 - a3 * u2 - a4 * u3;
//
//
//	//SATURATION HERE...  IF YOU REALLY NEED MORE JUICE...  UP THIS TO 1 and -1
//	if (u > .7) {
//		u = .7;
//	} else if (u < -.7) {
//		u = -.7;
//	}
//
//	u3 = u2;
//	u2 = u1;
//	u1 = u;
//
//	if (u > 0) {
//		//Commutation phase offset
//		indexCount += 512 - rotorOffset; //Phase offset of 90 degrees.
//		dummy_u = u;
//	} else {
//		indexCount += -512 - rotorOffset; //Phase offset of 90 degrees.
//		dummy_u = -u;
//	}
//
//	indexCount = (-indexCount + 2048) % 2048;
//
//
//	SpaceVectorModulation(SVPWMTimeCalc(InversePark(dummy_u, 0, indexCount)));
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


	//	size = sprintf((char *) out, "%i, %i, %i, %u, %i, %i\r\n",
	//		GH_A_DC, GH_B_DC, GH_C_DC, sv.sector, (int16_t) (sv.Va * 1000), (int16_t) (sv.Vb * 1000)
	//		);
	//	DMA0_UART2_Transfer(size, out);
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
		cos_position = (2048 + ((position1 + 512) % 2048)) % 2048; //TODO: SPEED THIS UP!!!!!!
	} else {
		position = position1 % 2048;
		cos_position = (position1 + 512) % 2048;
	}

	cosine = TRIG_DATA[cos_position];
	sine = TRIG_DATA[position];

	//float cosine = 0;
	//float sine = 0;

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

#endif