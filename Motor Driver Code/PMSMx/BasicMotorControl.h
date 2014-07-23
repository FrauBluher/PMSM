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
 * @file	BasicMotorControl.h
 * @author 	Pavlo Manovi
 * @date	March 21st, 2014
 * @brief 	This library provides control methods for the DRV8301.
 *
 * This library provides methods for basic trapezoidal control for a BLDC motor.
 *
 */

#ifndef BASICMOTORCONTROL_H
#define	BASICMOTORCONTROL_H

enum {
    CW,
    CCW
};


void ForceDuty(int GH_A, int GL_A, int GH_B, int GL_B, int GH_C, int GL_C);

//Torque is between 0 and 999, and direction is either CW or CCW.
void TrapUpdate(int torque, int direction);

#endif	/* BASICMOTORCONTROL_H */

