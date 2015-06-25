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
 * This library provides implementation of a 3rd order LQG controller for a PMSM motor with
 * block commutation provided by hall effect sensors and a Change Notification interrupt system.
 * This LQG controller has the estimator and all other values exposed for experimentation.
 *
 * As of Sept. 2014 this method is included only as a method of integrating BLDC motors easily 
 * with the PMSMx module.  For use with the SUPER-Ball Bot and the geared Maxon Motors, please
 * use PMSM.c for motor control with the #SINE definition.
 * 
 * Note: To use this method of motor control CN must be set up.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "PMSM_Velocity.h"
#include "PMSMBoard.h"
#include "DMA_Transfer.h"
#include <uart.h>
#include <xc.h>
#include <dsp.h>
#include <math.h>
#include <qei32.h>

#if defined VELOCITY

#include "TrigData.h"

#define SQRT_3_2 0.86602540378
#define SQRT_3 1.732050807568877
//#define SPOOL_SCALING_FACTOR 565.486683301
#define TWO_PI 6.283185307
#define SPOOL_RADIUS_MM 15
#define LOOP_TIME_S 0.000333
#define SPOOL_CIRCUMFERENCE_MM (TWO_PI*SPOOL_RADIUS_MM)
#define	SPOOL_SCALING_FACTOR (SPOOL_CIRCUMFERENCE_MM)/LOOP_TIME_S //used full pi instead of 3.14
#define PULSES_PER_REVOLUTION 223232

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

static float speed;
static float u = 0;
static float d_u = 0;
static float y = 0;

static float cableVelocity;

static int32_t indexCount = 0;
static int32_t runningPositionCount = 0;
static int32_t runningPosition2 = 0;
static int32_t lastRunningPostionCount = 0;
int32_t intermediatePosition;

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

/**
 * @brief Called by CN Interrupt to update commutation.
 */
void TrapUpdate(uint16_t torque, uint16_t direction);

void SpaceVectorModulation(TimesOut sv);
InvClarkOut InverseClarke(InvParkOut pP);
InvParkOut InversePark(float Vd, float Vq, int16_t position);
TimesOut SVPWMTimeCalc(InvParkOut pP);

/**                          Public Functions                                **/

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
			__builtin_nop();
		}
		theta1 -= 1;
	}

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(0.8, 0, 0)));
	while (j < 800000) {
		Nop();
		j++;
	}

	Write32bitQEI1IndexCounter(&w);
	Write32bitQEI1PositionCounter(&w);

	SpaceVectorModulation(SVPWMTimeCalc(InversePark(0, 0, 0)));

	return(0);
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

/**
 * @brief Sets the commanded position of the motor.
 * @param pos The position of the rotor in radians.
 *
 * This method sets the angular position of the controller.
 */
void SetVelocity(float velocity)
{
	speed = velocity;
}

/**
 * @brief Call this to update the controller at a rate of 3kHz.
 * @param speed Speed to set controller to follow.
 * 
 * It is required that the LQG controller which was characterized at a sample rate of n Hz is
 * run every n Hz with this function call.
 */
void PMSM_Update_Velocity(void)
{
	indexCount = Read32bitQEI1PositionCounter();
	int32_t delta;
	intermediatePosition = (runningPositionCount + indexCount);

	delta = intermediatePosition - runningPosition2;


	y = speed - (((float) (int32_t) (delta) * 0.0030679616) * 3000);

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
}

/****************************   Private Stuff   *******************************/

void SpaceVectorModulation(TimesOut sv)
{
	switch (sv.sector) {
	case 1:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - .375 * sv.Vb - .649519 * sv.Va)) - 10;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + .375 * sv.Vb - .216506 * sv.Va)) - 10;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 - .375 * sv.Vb + .216506 * sv.Va)) - 10;
		break;
	case 2:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - .433013 * sv.Va)) - 10;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + .75 * sv.Vb)) - 10;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 + .433013 * sv.Va)) - 10;
		break;
	case 3:
		GH_A_DC = ((uint16_t) PHASE1 * (.5 - 0.375 * sv.Vb + .216506 * sv.Va)) - 10;
		GH_B_DC = ((uint16_t) PHASE1 * (.5 + 0.375 * sv.Vb + .216506 * sv.Va)) - 10;
		GH_C_DC = ((uint16_t) PHASE1 * (.5 - 0.375 * sv.Vb + .649519 * sv.Va)) - 10;
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
	static uint8_t out[56];
	static uint8_t size;

	TimesOut t;
	t.sector = ((uint8_t) (.0029296875 * (indexCount) + 6)) % 3 + 1;

	size = sprintf((char *) out, "%u\r\n", t.sector);
	DMA0_UART2_Transfer(size, out);

	t.Va = pP.Va;
	t.Vb = pP.Vb;

	return(t);
}

/**
 * This function should exclusively be called by the change notify interrupt to
 * ensure that all hall events have been recorded and that the time between events
 * is appropriately read.  When using QEI and FOC, this routine is not used.
 *
 * The only other conceivable time that this would be called is if the motor is currently
 * not spinning.
 *
 * TODO: Look into preempting this interrupt and turning off interrupts when adding
 * data to the circular buffers as they are non-reentrant.  Calling this function
 * may break those libraries.
 * @param torque
 * @param direction
 */
void TrapUpdate(uint16_t torque, uint16_t direction)
{
	if (torque > PTPER) {
		torque = PTPER;
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
		TrapUpdate((uint16_t) (-1 * u * PTPER), CCW);
	} else if (u >= 0) {
		TrapUpdate((uint16_t) (u * PTPER), CW);
	}
	IFS1bits.CNIF = 0; // Clear CN interrupt
}

static int32_t lastCheck;
static int32_t currentCheck;

void __attribute__((__interrupt__, no_auto_psv)) _QEI1Interrupt(void)
{
	currentCheck = Read32bitQEI1PositionCounter();
	lastRunningPostionCount = runningPositionCount;
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
