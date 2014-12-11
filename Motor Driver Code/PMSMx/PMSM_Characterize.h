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
 * @file	PMSM_Characterize.h
 * @author 	Pavlo Manovi
 * @date 	July, 2013
 * @brief 	Provides methods for controlling PMSM motors sinusoidally.
 * 
 * This library provides methods for controlling torque, position, and air
 * gap flux linkages of permemant magnet synchronous motors, sinusoidally.
 * 
 */

#ifndef PMSM_CHARACTERIZE_H
#define PMSM_CHARACTERIZE_H

#include "PMSMBoard.h"

#ifdef SINE
#if defined (CHARACTERIZE_POSITION) || defined (CHARACTERIZE_VELOCITY)

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
 * @brief PMSM initialization call. Sets up hardware and timers.
 * @param *information a pointer to the MotorInfo struct that will be updated.
 * @return Returns 1 if successful, returns 0 otherwise.
 *
 * This needs to be called after all other hardware peripherals have been initialized.
 * It is up to you to set newData to zero, it is set to one every time a new position is commanded.
 * Setting newData to zero isn't required and newData itself is provided only for implementation purposes.
 * 
 * PMSM_Init uses Timer2 and sets up the processor.
 */
uint8_t PMSM_Init(MotorInfo *information);

#ifdef CHARACTERIZE_POSITION
/**
* @brief Sets the commanded position of the motor.
* @param pos The position of the rotor in radians.
*
* This method sets the angular position of the controller.
*/
void SetPosition(float pos);
#endif
#ifdef CHARACTERIZE_VELOCITY
/**
* @brief Sets the commanded velocity of the motor.
* @param pos The velocity of the rotor in radians/second.
*
* This method sets the angular velocity of the controller.
*/
void SetVelocity(float pos);
#endif

/**
 * @brief calculates PMSM vectors and updates the init'd MotorInfo struct with duty values.
 *
 * This should be called after one is done updating position, field weakening, and torque.
 * Call only once after all three are updated, not after setting each individual parameter.
 */
void CharacterizeStep(void);

#endif    /*PMSM_CHARACTERIZE_H  */
#endif
#endif