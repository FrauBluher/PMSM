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
 * @file	PMSM.h
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

#ifndef PMSM_H
#define PMSM_H

#ifndef CHARACTERIZE

#include <stdint.h>

#if defined(__dsPIC33FJ128MC802__)
#define FCY 40000000
#warning The 33F PMSM implementation is unsupported at this time.
#endif
#if defined(__dsPIC33EP256MC506__)
#define FCY 70000000
#endif

#define MOTOR_PWM_FREQ 20000

//Provided for implementation.  Use floats.
#define RADTODEG(x) ((x) * 57.29578)
#define DEGTORAD(x) ((x) * 0.0174532925))

/**
 * @brief A structure which holds information about the motor, and driver.
 *
 * A variable of type MotorInfo must be declared in a scope that allows its address to
 * be passed to PMSM_Init.
 */
typedef struct {
    double t1;
    double t2;
    double t3;
    uint8_t newData;
} MotorInfo;

/**
 * @brief PMSM initialization call.  Calibrates rotor offset.
 * @param *information a pointer to the MotorInfo struct that will be updated.
 * @return Returns 1 if successful, returns 0 otherwise.
 *
 * This must be called before PMSM_Update is called.
 */
uint8_t PMSM_Init(MotorInfo *information);

/**
 * @brief Updates the motor commutation and position control.  Call at 3kHz.
 *
 */
void PMSM_Update(void);

/**
 * @brief Sets the commanded position of the motor.
 * @param pos The position of the rotor in radians.
 * 
 * This method sets the angular position of the controller.
 */
void SetPosition(float pos);

/**
 * @brief Sets the commanded torque of the motor.
 * @param power Percentage of torque requested from 0 - 100%.
 * 
 * Scales the sinusoidal modulation index.  This method isn't used when LQG control is
 * enabled, but is included for future impedance controller integration.
 */
void SetTorque(uint8_t power);

/**
 * @brief Sets the air gap flux linkage value.
 * @param Id Air gap flux linkage timing advance.  ~0 to -2.5.
 * 
 * Field weakening changes the air gap flux linkage, this can cunteract BEMF and allow
 * a motor to spin faster than its rated speed.  Make sure you know what you are doing
 * with this value or you can demagnetize your motor magnets, melt windings, or rip your
 * motor apart.
 *
 * Suggested reading for air-gap flux linkage control:
 * http://ww1.microchip.com/downloads/en/AppNotes/01078B.pdf
 *
 */
void SetAirGapFluxLinkage(float id);


#endif    /*PMSM_H  */
#endif
