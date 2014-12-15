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

#ifndef PMSM_VELOCITY_H
#define	PMSM_VELOCITY_H

#include "PMSMBoard.h"

#ifdef VELOCITY

#include <stdint.h>

typedef struct {
    uint16_t hallCount;
    uint16_t lastHallCount;
    uint16_t currentSpeed;
    uint16_t lastHallState;
} BasicMotorControlInfo;

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

enum {
    CW,
    CCW
};

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

/**
 * @brief Calculates last known cable length and returns it.
 * @return Cable length in mm.
 */
int32_t GetCableLength(void);

/**
 * @brief Sets the commanded position of the motor.
 * @param pos The position of the rotor in radians.
 *
 * This method sets the angular position of the controller.
 */
void SetVelocity(float velocity);

/**
 * @brief Call this to update the controller at a rate of 3kHz.
 * 
 * It is required that the LQG controller which was characterized at a sample rate of n Hz is
 * run every n Hz with this function call.
 */
void PMSM_Update_Velocity(void);
#endif
#endif	/* PMSM_VELOCITY_H */
