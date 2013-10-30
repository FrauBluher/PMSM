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
#include <stdlib.h>
#include <stdint.h>
#include "PMSM.h"
#include "PMSM_Sinusoidal_Drive.h"     /* Model's header file */
#include "rtwtypes.h"                  /* MathWorks types */

#warning The motor driver code is in alpha.

extern D_Work_PMSM_Sinusoidal_Drive PMSM_Sinusoidal_Drive_DWork;
extern real32_T commandedAngle; 		/* '<Root>/Data Store Memory' */
extern real32_T torqueInput; 			/* '<Root>/Data Store Memory11' */
extern real32_T fieldWeakening; 		/* '<Root>/Data Store Memory9' */

MotorInfo *passedLocation;

/**
 * @brief PMSM initialization call. Sets up hardware and timers.
 * @param *information a pointer to the MotorInfo struct that will be updated.
 * @return Returns 1 if successful, returns 0 otherwise.
 */
uint8_t PMSM_Init(MotorInfo *information) {
        if (information != NULL) {
            PMSM_Sinusoidal_Drive_initialize();
            passedLocation = information;
            return(1);
        } else {
            return(0);
        }
}

/**
 * @brief Sets the commanded position of the motor.
 * @param pos The position of the rotor in radians from 0 - 2pi / n-poles.
 */
void SetPosition(float pos) {
	commandedAngle = pos;
}

/**
 * @brief Sets the commanded torque of the motor.
 * @param power Percentage of torque requested from 0 - 100%.
 */
void SetTorque(uint8_t power) {
	torqueInput = power;
}

/**
 * @brief Sets the air gap flux linkage value.
 * @param Id Air gap flux linkage timing advance.  ~0 to -2.5.
 */
void SetAirGapFluxLinkage(float Id) {
	fieldWeakening = Id;
}

/**
 * @brief calculates PMSM vectors and updates the init'd MotorInfo struct with duty values.
 *
 * This should be called after one is done updating position, field weakening, and torque.
 * Call only once after all three are updated, not after setting each individual parameter.
 */
void PMSM_Update(void) {
    	PMSM_Sinusoidal_Drive_step();
	passedLocation->t1 = PMSM_Sinusoidal_Drive_DWork.T1;
	passedLocation->t2 = PMSM_Sinusoidal_Drive_DWork.T2;
	passedLocation->t3 = PMSM_Sinusoidal_Drive_DWork.T3;
        passedLocation->newData = 1;
}