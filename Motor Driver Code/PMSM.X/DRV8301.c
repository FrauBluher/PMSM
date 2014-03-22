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
 * @file	DRV8301.c
 * @author 	Pavlo Manovi
 * @date	October, 2013
 * @brief 	This library provides implementation of control methods for the DRV8301.
 *
 * This library provides implementation of control methods for the DRV8301.
 *
 */


#include <xc.h>
#include <stdint.h>
#include <stdlib.h>
#include "SPIdsPIC.h"
#include "DRV8301.h"

static uint8_t initGuardDRV8301 = 0;
static DRV8301_Info *passedInfoStruct;

/**
 * @brief Allows for you to turn the half bridges to high-impedance mode.
 * @param gateEnable One or zero for on and off.
 */
uint8_t DRV8301_Init(DRV8301_Info *drv8301Info)
{
	DRV8301_STATUSREGISTER2 tempStatus;

	//Until the 8301 error reporting state machine is finished this is to remain
	//commented out!
	//	if (initGuardDRV8301 == 1) {
	//		return(EXIT_FAILURE);
	//	}

	drv8301Info->controlRegister1.GATE_CURRENT = GATE_CURRENT_1_7A;
	drv8301Info->controlRegister1.PWM_MODE = PWM_MODE_SIX_CHAN;
	drv8301Info->controlRegister1.GATE_RESET = GATE_RESET_OFF;
	drv8301Info->controlRegister1.OC_MODE = GD_OC_MODE_OFF;
	drv8301Info->controlRegister1.OC_ADJ_SET = OC_ADJ_SET_0_822V;

	drv8301Info->controlRegister2.DC_CAL_CH1 = DC_CAL_CH1_OFF;
	drv8301Info->controlRegister2.DC_CAL_CH2 = DC_CAL_CH2_OFF;
	drv8301Info->controlRegister2.GAIN = GAIN_10V;
	drv8301Info->controlRegister2.OC_TOFF = OC_TOFF_CBC;
	drv8301Info->controlRegister2.OCTW_SET = OCTW_SET_OCTW;

	//Dummy Reads
	tempStatus.wholeRegister = SPI2_ReadFromReg(CONTROL_REGISTER1_ADDR);
	tempStatus.wholeRegister = SPI2_ReadFromReg(CONTROL_REGISTER2_ADDR);

	SPI2_WriteToReg(CONTROL_REGISTER1_ADDR,
		drv8301Info->controlRegister1.wholeRegister);
	SPI2_WriteToReg(CONTROL_REGISTER2_ADDR,
		drv8301Info->controlRegister2.wholeRegister);

	tempStatus.wholeRegister = SPI2_ReadFromReg(CONTROL_REGISTER1_ADDR);
	tempStatus.wholeRegister = SPI2_ReadFromReg(CONTROL_REGISTER2_ADDR);

	passedInfoStruct = drv8301Info;
	initGuardDRV8301 = 1;

	return(EXIT_SUCCESS);
}

/**
 * @brief Enable/Disable DC Calibration
 * @return Updates DRV8301_Info with current information and sets newData to 1.
 */
void DRV8301_UpdateStatus(void)
{
	passedInfoStruct->statusRegister1.wholeRegister =
		SPI2_ReadFromReg(STATUS_REGISTER1_ADDR);
	passedInfoStruct->statusRegister1.wholeRegister =
		SPI2_ReadFromReg(STATUS_REGISTER2_ADDR);
	SPI2_ReadFromReg(CONTROL_REGISTER1_ADDR);
	SPI2_ReadFromReg(CONTROL_REGISTER2_ADDR);
	passedInfoStruct->newData = 1;
}

/**
 * @brief Resets the DRV8301 and resets any latched faults.
 */
void DRV8301_Reset(void)
{
	passedInfoStruct->controlRegister1.GATE_RESET = GATE_RESET_ON;
	SPI2_WriteToReg(CONTROL_REGISTER1_ADDR,
		passedInfoStruct->controlRegister1.wholeRegister);
}

/**
 * @brief Enable/Disable DC Calibration
 * @param enable 1 to enable dc calibration 0 to disable dc calibration.
 */
void DRV8301_DCCalibration(uint8_t enable)
{
	if (enable) {
		passedInfoStruct->controlRegister2.DC_CAL_CH1 = DC_CAL_CH1_ON;
		passedInfoStruct->controlRegister2.DC_CAL_CH2 = DC_CAL_CH2_ON;
	} else {
		passedInfoStruct->controlRegister2.DC_CAL_CH1 = DC_CAL_CH1_OFF;
		passedInfoStruct->controlRegister2.DC_CAL_CH2 = DC_CAL_CH2_OFF;
	}

	SPI2_WriteToReg(CONTROL_REGISTER2_ADDR,
		passedInfoStruct->controlRegister2.wholeRegister);
}