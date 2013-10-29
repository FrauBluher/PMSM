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

#ifndef DRV8301_H
#define	DRV8301_H

#include <xc.h>
#include <stdint.h>

/**
 * @brief Status and Control register values.
 */
#define STATUS_REGISTER1    0x0 //Fault reports
#define STATUS_REGISTER2    0x1 //Device ID and Fault Reports
#define CONTROL_REGISTER1   0x2
#define CONTROL_REGISTER2   0x3

/**
 * @brief STATUS_REGISTER1 Data bit positions.
 */
#define FAULT_GENERAL       0x400
#define GVDD_UV             0x200
#define PVDD_UV             0x100
#define OTSD                0x80
#define OTW                 0x40
#define FETHA_OC            0x20
#define FETLA_OC            0x10
#define FETHB_OC            0x8
#define FETLB_OC            0x4
#define FETHC_OC            0x2
#define FETLC_OC            0x1

/**
 * @brief STATUS_REGISTER2 Data bit positions.
 */
#define GVDD_OV             0x80
#define DEVICE_ID_D3        0x8
#define DEVICE_ID_D2        0x4
#define DEVICE_ID_D1        0x2
#define DEVICE_ID_D0        0x1

/*~~~~~~~~~~~~~~~~~~~~~~~~~CONTROL REGISTER 1 OPTIONS~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/**
 * @brief Gate drive current limiting.
 */
#define GATE_CURRENT_1_7A   0x0
#define GATE_CURRENT_0_7A   0x1
#define GATE_CURRENT_0_25A  0x2
/* ^^^ Choose only one of the ABOVE to OR together with the other options. ^^^ */

#define GATE_RESET          0x4  //Resets latched faults, sets to 0 after reset
#define PWM_MODE_THREE_CHAN 0x8  //Default: Six channel mode.

/**
 * @brief Gate drive overcurrent behavior
 */
#define GD_OC_MODE_SHTDWN   0x10 //Default: Current limit on OC. Shutdown on gate OC.
#define GD_OC_MODE_RPRT     0x20 //Report only, no current limiting or latching.
#define GD_OC_MODE_OFF      0x30 //Turn off gate OC sensing/reporting/latching
/* ^^^ Choose only one of the ABOVE to OR together with the other options. ^^^ */

/**
 * @brief Internal current sense voltage divider reference set for output OC sense.
 */
#define OC_ADJ_SET_0_060V   0x40
#define OC_ADJ_SET_0_068V   0x80
#define OC_ADJ_SET_0_076V   0xC0
#define OC_ADJ_SET_0_086V   0x100
#define OC_ADJ_SET_0_097V   0x140
#define OC_ADJ_SET_0_109V   0x180
#define OC_ADJ_SET_0_123V   0x1C0
#define OC_ADJ_SET_0_138V   0x200
#define OC_ADJ_SET_0_155V   0x240
#define OC_ADJ_SET_0_175V   0x280
#define OC_ADJ_SET_0_197V   0x2C0
#define OC_ADJ_SET_0_222V   0x300
#define OC_ADJ_SET_0_250V   0x340
#define OC_ADJ_SET_0_282V   0x380
#define OC_ADJ_SET_0_317V   0x3C0
#define OC_ADJ_SET_0_358V   0x400
#define OC_ADJ_SET_0_403V   0x440
#define OC_ADJ_SET_0_454V   0x480
#define OC_ADJ_SET_0_511V   0x4C0
#define OC_ADJ_SET_0_576V   0x500
#define OC_ADJ_SET_0_648V   0x540
#define OC_ADJ_SET_0_730V   0x580
#define OC_ADJ_SET_0_822V   0x5C0
#define OC_ADJ_SET_0_926V   0x600
#define OC_ADJ_SET_1_043V   0x640
#define OC_ADJ_SET_1_175V   0x680
#define OC_ADJ_SET_1_324V   0x6C0
#define OC_ADJ_SET_1_491V   0x700
#define OC_ADJ_SET_1_679V   0x740       //Do not use if PVDD is 6V - 8V
#define OC_ADJ_SET_1_892V   0x780       //Do not use if PVDD is 6V - 8V
#define OC_ADJ_SET_2_131V   0x7C0       //Do not use if PVDD is 6V - 8V
#define OC_ADJ_SET_2_400V   0x800       //Do not use if PVDD is 6V - 8V
/* ^^^ Choose only one of the ABOVE to OR together with the other options. ^^^ */

/*~~~~~~~~~~~~~~~~~~~~~~~~~CONTROL REGISTER 2 OPTIONS~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/**
 * Default value is a gain of 10V/V
 * @brief Current sense amplifier gain amplification.
 */
#define GAIN_20V            0x4
#define GAIN_40V            0x8
#define GAIN_80V            0xC
/* ^^^ Choose only one of the ABOVE to OR together with the other options. ^^^ */

/**
 * @brief Shorts input pins of amps so that one can remove dc bias from ADCs.
 */
#define DC_CAL_CH1          0x10
#define DC_CAL_CH1          0x20



uint8_t DRV8301_Init(uint16_t Parameters);
uint8_t DRV8301_Init(uint16_t Parameters);


void DRV8301_Reset(void);
void DRV8301_Reset(void);

/**
 * @brief Puts the driver board into current sensor calibration mode.
 * @param dcCal One or zero for on and off respectively.
 */
void DRV8301_CurrentSenseCalibration(uint8_t dcCal);

#endif	/* DRV8301_H */

