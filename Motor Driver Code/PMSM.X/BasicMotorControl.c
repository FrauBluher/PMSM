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
 * This library provides implementation of basic trapezoidal control for a BLDC motor.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "BasicMotorControl.h"
#include "PMSMBoard.h"

void ForceDuty(int GH_A, int GL_A, int GH_B, int GL_B, int GH_C, int GL_C)
{
	GH_A_DC = GH_A;
	GL_A_DC = GL_A;
	GH_B_DC = GH_B;
	GL_B_DC = GL_B;
	GH_C_DC = GH_C;
	GL_C_DC = GL_C;
}

void TrapUpdate(int torque, int direction)
{
	if (direction == CW) {
		if ((HALL1 && HALL2 && !HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = 0;
			GH_B_DC = torque;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = torque;
		} else if ((!HALL1 && HALL2 && !HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = torque;
			GH_B_DC = torque;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = 0;
		} else if ((!HALL1 && HALL2 && HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = torque;
			GH_B_DC = 0;
			GL_B_DC = 0;
			GH_C_DC = torque;
			GL_C_DC = 0;
		} else if ((!HALL1 && !HALL2 && HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = torque;
			GH_C_DC = torque;
			GL_C_DC = 0;
		} else if ((HALL1 && !HALL2 && HALL3)) {
			GH_A_DC = torque;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = torque;
			GH_C_DC = 0;
			GL_C_DC = 0;
		} else if ((HALL1 && !HALL2 && !HALL3)) {
			GH_A_DC = torque;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = torque;
		}
	} else if (direction == CCW) {
		if ((HALL1 && HALL2 && !HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = torque;
			GH_C_DC = torque;
			GL_C_DC = 0;
		} else if ((!HALL1 && HALL2 && !HALL3)) {
			GH_A_DC = torque;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = torque;
			GH_C_DC = 0;
			GL_C_DC = 0;
		} else if ((!HALL1 && HALL2 && HALL3)) {
			GH_A_DC = torque;
			GL_A_DC = 0;
			GH_B_DC = 0;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = torque;
		} else if ((!HALL1 && !HALL2 && HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = 0;
			GH_B_DC = torque;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = torque;
		} else if ((HALL1 && !HALL2 && HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = torque;
			GH_B_DC = torque;
			GL_B_DC = 0;
			GH_C_DC = 0;
			GL_C_DC = 0;
		} else if ((HALL1 && !HALL2 && !HALL3)) {
			GH_A_DC = 0;
			GL_A_DC = torque;
			GH_B_DC = 0;
			GL_B_DC = 0;
			GH_C_DC = torque;
			GL_C_DC = 0;
		}
	}
}