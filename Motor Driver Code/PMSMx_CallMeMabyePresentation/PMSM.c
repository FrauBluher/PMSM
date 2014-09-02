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
#include "PMSM.h"
#include "PMSMBoard.h"
#include "DMA_Transfer.h"
#include <uart.h>

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

static float theta;
static float Iq;
static float Id;

void CalcTimes(void);
void SpaceVectorModulation(InvClarkOut v);
InvClarkOut InverseClarke(InvParkOut pP);
InvParkOut InversePark(float Vd, float Vq, float position);


static float SVPWM_Rotation[2][2][6] = {
	{
		{0.7639, -0.358, -0.5243},
		{0.2752, -0.1471, -0.55},
		{-0.2592, 0.4365, 0.6546},},
};
/**
 * @brief PMSM initialization call. Sets up hardware and timers.
 * @param *information a pointer to the MotorInfo struct that will be updated.
 * @return Returns 1 if successful, returns 0 otherwise.
 */
uint8_t PMSM_Init(MotorInfo *information)
{
	if (information != NULL) {

		return(1);
	} else {
		return(0);
	}
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
	SpaceVectorModulation(InverseClarke(InversePark(0, .1, theta)));
}

static float T1, T2, Ta, Tb, Tc = 0;

/****************************   Private Stuff   *******************************/

void SpaceVectorModulation(InvClarkOut v)
{
	//	uint16_t size = 0;
	//	static uint8_t out[56];
	//	size = sprintf((char *) out, "%g,%g,%g\r\n", v.Vr1, v.Vr2, v.Vr3);
	//	DMA0_UART2_Transfer(size, out);
	static int sector;
	if (v.Vr1 >= 0) {
		// (xx1)
		if (v.Vr2 >= 0) {
			// (x11)
			// Must be Sector 3 since Sector 7 not allowed
			// Sector 3: (0,1,1)  0-60 degrees
			T1 = v.Vr2;
			T2 = v.Vr1;
			CalcTimes();
			GH_A_DC = (uint16_t) Ta;
			GH_B_DC = (uint16_t) Tb;
			GH_C_DC = (uint16_t) Tc;
			sector = 3;
		} else {
			// (x01)
			if (v.Vr3 >= 0) {
				// Sector 5: (1,0,1)  120-180 degrees
				T1 = v.Vr1;
				T2 = v.Vr3;
				CalcTimes();
				GH_A_DC = (uint16_t) Tc;
				GH_B_DC = (uint16_t) Ta;
				GH_C_DC = (uint16_t) Tb;
				sector = 5;
			} else {
				// Sector 1: (0,0,1)  60-120 degrees
				T1 = -v.Vr2;
				T2 = -v.Vr3;
				CalcTimes();
				GH_A_DC = (uint16_t) Tb;
				GH_B_DC = (uint16_t) Ta;
				GH_C_DC = (uint16_t) Tc;
				sector = 1;
			}
		}
	} else {
		// (xx0)
		if (v.Vr2 >= 0) {
			// (x10)
			if (v.Vr3 >= 0) {
				// Sector 6: (1,1,0)  240-300 degrees
				T1 = v.Vr3;
				T2 = v.Vr2;
				CalcTimes();
				GH_A_DC = (uint16_t) Tb;
				GH_B_DC = (uint16_t) Tc;
				GH_C_DC = (uint16_t) Ta;
				sector = 6;
			} else {
				// Sector 2: (0,1,0)  300-0 degrees
				T1 = -v.Vr3;
				T2 = -v.Vr1;
				CalcTimes();
				GH_A_DC = (uint16_t) Ta;
				GH_B_DC = (uint16_t) Tc;
				GH_C_DC = (uint16_t) Tb;
				sector = 2;
			}
		} else {
			// (x00)
			// Must be Sector 4 since Sector 0 not allowed
			// Sector 4: (1,0,0)  180-240 degrees
			T1 = -v.Vr1;
			T2 = -v.Vr2;
			CalcTimes();
			GH_A_DC = (uint16_t) Tc;
			GH_B_DC = (uint16_t) Tb;
			GH_C_DC = (uint16_t) Ta;
			sector = 4;
		}
	}
}

InvClarkOut InverseClarke(InvParkOut pP)
{
	InvClarkOut returnVal;
	returnVal.Vr1 = pP.Vb;
	returnVal.Vr2 = (-pP.Vb / 2 + (SQRT_3_2 * pP.Va));
	returnVal.Vr3 = (-pP.Vb / 2 - (SQRT_3_2 * pP.Va));
	return(returnVal);
}

InvParkOut InversePark(float Vd, float Vq, float position)
{
	InvParkOut returnVal;
	returnVal.Va = Vd * cosf(theta) - Vq * sinf(position);
	returnVal.Vb = Vd * sinf(theta) + Vq * cosf(position);
	return(returnVal);
}

void CalcTimes(void)
{
	Ta = 0;
	Tb = 0;
	Tc = 0;

	T1 = PWM * T1;
	T2 = PWM * T2;
	Tc = (PWM - T1 - T2) / 2;
	Tb = Tc + T1;
	Ta = Tb + T2;
}