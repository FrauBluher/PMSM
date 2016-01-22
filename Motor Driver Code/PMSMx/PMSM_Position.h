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

#ifndef PMSM_POSITION_H
#define PMSM_POSITION_H
#ifdef POSITION

#ifndef CHARACTERIZE_POSITION
#ifndef CHARACTERIZE_VELOCITY

#include <stdint.h>

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
 * @brief Sets the commanded position of the motor.
 * @param pos The position of the rotor in radians.
 *
 * This method sets the angular position of the controller.
 */
void SetPosition(float pos);
void SetPositionInt(int32_t pos);

/**
 * @brief Returns last known cable velocity in mm/s.
 * @return Cable velocity in mm/S.
 */
int32_t GetCableVelocity(void);

/**
 * @brief Calculates last known cable length and returns it.
 * @return Cable length in mm.
 */
int32_t GetCableLength(void);

/**
 * @brief Call this to update the controller at a rate of 1kHz.
 *
 * It is required that the LQG controller which was characterized at a sample rate of n Hz is
 * run every n Hz with this function call.
 */
void PMSM_Update_Position(void);

/**
 * @brief Call this to update the commuatation of the motor as fast as possible
 *
 * This should run at around 10-15 kHz.
 */
void PMSM_Update_Commutation(void);

#endif    /*PMSM_POSITION_H  */
#endif
#endif
#endif