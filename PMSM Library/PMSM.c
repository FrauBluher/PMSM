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
 * @brief 	Provides implementation for controlling PMSM motors with dsPIC 33F/E's
 * 
 * This library provides methods for controlling torque, position, and air
 * gap flux linkages of permemant magnet synchronous motors, sinusoidally.  It has
 * been written for use with the dsPIC33F/E on DRV8302 based controllers, specifically
 * the PMSM board available on pavlo.me.
 * 
 * With these methods it is possible to implement a controller wrapping position,
 * speed, or torque into any control schema.
 *
 * If being used with the CAN enabled PMSM Board obtained at either pavlo.me or off of
 * http://github.com/FrauBluher/ as of v 1.4 the following pins are reserved on the
 * dsPIC33EP256MC506:
 *
 * -    PIN FUNCTIONS   -  PIN #  -  USAGE
 * - RPI44/PWM2H/RB12   - Pin 62  -  PWM2
 * - RP42/PWM3H/RB10    - Pin 60  -  PWM3
 * - RP97/RF1           - PIN 59  -  CANTX (VIA PPS)
 * - RPI96/RF0          - PIN 58  -  CANRX (VIA PPS)
 * - RD6                - PIN 54  -  PWRGD
 * - RD5                - PIN 53  -  OCTW
 * - RP56/RC8           - PIN 52  -  FAULT
 * - RP55/RC7           - PIN 51  -  GAIN
 * - RP54/RC6           - PIN 50  -  EN_GATE
 * - TMS/ASDA1/RP41/RB9 - PIN 49  -  DC_CAL
 * - TP40/T4CK/ACL1/RB8 - PIN 48  -  LED1
 * - RC13               - PIN 47  -  LED2
 * - RP39/INT0/RB7      - PIN 46  -  LED3
 * - RPI58/RC10         - PIN 45  -  LED4
 * - PGEC2/RP38/RB6     - PIN 44  -  PGC
 * - PGED2/RP37/RB5     - PIN 43  -  PGD
 * - SDA1/RPI52/RC4     - PIN 36  -  EN_A
 * - SCK1/RPI51/RC3     - PIN 35  -  EN_B
 * - SDI1/RPI25/RA9     - PIN 34  -  EN_C
 * - RPI46/PWM1H/RB14   - PIN 2   -  PWM1
 * - AN0/OA2OUT/RA0     - PIN 13  -  CRNT1 (Current Sens)
 * - AN1/C2IN1+/RA1     - PIN 14  -  CRNT2 (Current Sens)
 *
 */

#include <xc.h>
#include <stdlib.h>
#include <stdint.h>
#include "PMSM.h"
#include "PMSM_Sinusoidal_Drive.h"     /* Model's header file */
#include "rtwtypes.h"                  /* MathWorks types */

#if defined(__dsPIC33FJ128MC802__)
#warning The 33F PMSM implementation is unsupported at this time.
#endif
#if defined(__dsPIC33EP256MC506__)
#warning The motor driver code is in alpha.
#endif

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
 * @brief Allows for you to turn the half bridges to high-impedance mode.
 * @param gateEnable One or zero for on and off.
 */
void GateControl(uint8_t gateEnable) {
	LATCbits.LATC6 = gateEnable;
}

/**
 * @brief Puts the driver board into current sensor calibration mode.
 * @param dcCal One or zero for on and off respectively.
 */
void CurrentSenseCalibration(uint8_t dcCal) {
	LATBbits.LATB9 = dcCal;
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