/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Pavlo Milo Manovi
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <xc.h>
#include <stdint.h>
#include <stdlib.h>
#include "SPIdsPIC.h"
#include "DRV8301.h"


static uint8_t initGuardDRV8301 = 0;


uint8_t DRV8301_Init(uint16_t Parameters){

}

/**
 * @brief Allows for you to turn the half bridges to high-impedance mode.
 * @param gateEnable One or zero for on and off.
 */
void GateControl(uint8_t gateEnable) {
	//LATCbits.LATC6 = gateEnable;
}

/**
 * @brief Puts the driver board into current sensor calibration mode.
 * @param dcCal One or zero for on and off respectively.
 */
void CurrentSenseCalibration(uint8_t dcCal) {
	LATBbits.LATB9 = dcCal;
}