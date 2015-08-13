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

#include "PMSMBoard.h"

#if defined (CHARACTERIZE_POSITION) || defined (CHARACTERIZE_VELOCITY)
//Something here
#else
#if defined POSITION
#include <xc.h>
#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "PMSM_Position.h"
#include "DMA_Transfer.h"
#include "cordic.h"
#include <qei32.h>
#include <uart.h>
#include "FixedPointSVM/FOC_FixedPoint.h"

#include "../CAN Testing/canFiles/motor_can.h"

#ifndef CHARACTERIZE
#include "TrigData.h"
#include "FixedPointSVM/FOC_FromScratch.h"

#define SQRT_3_2 0.86602540378
#define SQRT_3 1.732050807568877
//#define SPOOL_SCALING_FACTOR 565.486683301
#define TWO_PI 6.283185307
#define SPOOL_RADIUS_MM 15
#define LOOP_TIME_S 0.000333
#define SPOOL_CIRCUMFERENCE_MM (TWO_PI*SPOOL_RADIUS_MM)
#define	SPOOL_SCALING_FACTOR (SPOOL_CIRCUMFERENCE_MM)/LOOP_TIME_S //used full pi instead of 3.14
#define PULSES_PER_REVOLUTION 223232

#define TRANS QEI1STATbits.IDXIRQ
#define POS QEI1STATbits.PCHEQIRQ
#define NEG QEI1STATbits.PCLEQIRQ
#define ZERO QEI1STATbits.POSOVIRQ

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

static volatile float theta;
static float d_u;
static float y;
static float cableVelocity;
static float u = 0;

static int32_t indexCount = 0;
static int32_t runningPositionCount = 0;
static int32_t intermediatePosition = 0;
static int32_t lastRunningPostionCount = 0;

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
	{0.167525299197710, 0.853873229166799, -0.054110207360082},
	{-0.557698239898382, 0.248028266562591, 0.116156944634215},
	{0.235670999753073, 0.436664074501789, -0.649680555994633}

};

static float L[3][1] = {
	{ -0.011927622324162},
	{0.464575420462811},
	{0.330672683026544}
};

static float K[1][3] = {
	{0.310247462375861, -0.093017922302088, -0.789859907625239}
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
	FOC_Init();

	static int32_t theta1;
	int32_t i;
	uint32_t j;
	qeiCounter w;

	w.l = 0;
	theta1 = 0;

	FOC_Update_Commutation(.5 * 32767, 0);
	while (j < 1500000) {
		Nop();
		j++;
	}

	Write32bitQEI1IndexCounter(&w);
	Write32bitQEI1PositionCounter(&w);
	runningPositionCount = 0;

	FOC_Update_Commutation(0, 0);
}

/**
 * @brief Sets the commanded position of the motor.
 */
void SetPosition(float pos)
{
    if (pos != theta) {
	theta = pos;
    }
}

/**
 * @brief Calculates last known cable length and returns it.
 * @return Cable length in mm.
 */
int32_t GetCableLength(void)
{

	return((runningPositionCount / PULSES_PER_REVOLUTION) *
		SPOOL_CIRCUMFERENCE_MM);
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
		PULSES_PER_REVOLUTION) * SPOOL_SCALING_FACTOR;

	return((int32_t) cableVelocity);
}

void PMSM_Update_Position(void)
{
	indexCount = Read32bitQEI1PositionCounter();

	y = theta - ((float) (int32_t) (indexCount) * 0.0030679616); //Scaling it back into radians.

//	x_dummy[0][0] = (x_hat[0][0] * K_reg[0][0]) + (x_hat[1][0] * K_reg[0][1]) + (x_hat[2][0] * K_reg[0][2]) + (L[0][0] * y);
//	x_dummy[1][0] = (x_hat[1][0] * K_reg[1][0]) + (x_hat[1][0] * K_reg[1][1]) + (x_hat[2][0] * K_reg[1][2]) + (L[1][0] * y);
//	x_dummy[2][0] = (x_hat[2][0] * K_reg[2][0]) + (x_hat[1][0] * K_reg[2][1]) + (x_hat[2][0] * K_reg[2][2]) + (L[2][0] * y);
//
//	x_hat[0][0] = x_dummy[0][0];
//	x_hat[1][0] = x_dummy[1][0];
//	x_hat[2][0] = x_dummy[2][0];
//
//	u = -1 * ((K[0][0] * x_hat[0][0]) + (K[0][1] * x_hat[1][0]) + (K[0][2] * x_hat[2][0]));

	u = y * 0.03;

	//SATURATION HERE...  IF YOU REALLY NEED MORE JUICE...  UP THIS TO 1 and -1
	if (u > 1) {
		u = 1;
	} else if (u < -1) {
		u = -1;
	}

//	CO(state_Current_Position) = (int32_t) ((float) indexCount * 0.02814643647496589);

	if (u > 0) {
		//Commutation phase offset
		FOC_Update_Commutation((int16_t) (u * 32767), indexCount + 512);//(int16_t) (d_u * 32767), indexCount);
	} else if (u < 0) {
		FOC_Update_Commutation((int16_t) (-u * 32767), indexCount - 512);//(int16_t) (d_u * 32767), indexCount);
	} else {
		FOC_Update_Commutation((int16_t) (0 * 32767), indexCount);//(int16_t) (d_u * 32767), indexCount);
	}
}

static int32_t lastCheck;
static int32_t currentCheck;

void __attribute__((__interrupt__, no_auto_psv)) _QEI1Interrupt(void)
{
	IFS3bits.QEI1IF = 0; /* Clear QEI interrupt flag */
}
#endif
#endif
#endif
