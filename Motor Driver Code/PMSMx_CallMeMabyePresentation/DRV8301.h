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
 *
 *
 * Using an SPI library, this module will provide methods for setting up a DRV8301.
 * This library will NOT handle EN_GATE, as that should be application specific.
 * Implement EN_GATE in your uC board init code.
 */

#ifndef DRV8301_H
#define	DRV8301_H

#include <xc.h>
#include <stdint.h>

/**
 * @brief Status and Control register values.
 */
#define STATUS_REGISTER1_ADDR    0x0000 //Fault reports
#define STATUS_REGISTER2_ADDR    0x0001 //Device ID and Fault Reports
#define CONTROL_REGISTER1_ADDR   0x0002
#define CONTROL_REGISTER2_ADDR   0x0003

/**
 * @brief STATUS_REGISTER1 Data bit positions.
 */
typedef struct {

    union {
        unsigned wholeRegister;

        struct {
            unsigned FETLC_OC : 1;
            unsigned FETHC_OC : 1;
            unsigned FETLB_OC : 1;
            unsigned FETHB_OC : 1;
            unsigned FETLA_OC : 1;
            unsigned FETHA_OC : 1;
            unsigned OTW : 1;
            unsigned OTSD : 1;
            unsigned PVDD_UV : 1;
            unsigned GVDD_UV : 1;
            unsigned FAULT_GENERAL : 1;
        };
    };
} DRV8301_STATUSREGISTER1;

/**
 * @brief STATUS_REGISTER2 Data bit positions.
 */
typedef struct {

    union {
        unsigned wholeRegister;

        struct {
            unsigned DEVICE_ID : 4;
            unsigned : 3;
            unsigned GVDD_OV : 1;
        };
    };
} DRV8301_STATUSREGISTER2;

/*~~~~~~~~~~~~~~~~~~~~~~~~~CONTROL REGISTER 1 OPTIONS~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/**
 * @brief CONTROL_REGISTER1 Data bit positions.
 */
typedef struct {

    union {
        unsigned wholeRegister;

        struct {
            unsigned GATE_CURRENT : 2;
            unsigned GATE_RESET : 1;
            unsigned PWM_MODE : 1;
            unsigned OC_MODE : 2;
            unsigned OC_ADJ_SET : 5;
        };
    };
} DRV8301_CONTROLREGISTER1;

/**
 * @brief GATE_CURRENT drive options.
 */
#define GATE_CURRENT_1_7A   0
#define GATE_CURRENT_0_7A   1
#define GATE_CURRENT_0_25A  2

/**
 * @brief GATE_RESET options.
 */
#define GATE_RESET_OFF      0
#define GATE_RESET_ON       1  //Resets latched faults, sets to 0 after reset

/**
 * @brief PWM_MODE options.
 */
#define PWM_MODE_SIX_CHAN   0  //Default: Six channel mode.
#define PWM_MODE_THREE_CHAN 1  //Default: Three channel mode.

/**
 * @brief OC_MODE options.
 */
#define GD_OC_MODE_LIMIT    0 //Default: Current limit on OC. Shutdown on gate OC.
#define GD_OC_MODE_SHTDWN   1 //Default: Current limit on OC. Shutdown on gate OC.
#define GD_OC_MODE_RPRT     2 //Report only, no current limiting or latching.
#define GD_OC_MODE_OFF      3 //Turn off gate OC sensing/reporting/latching

/**
 * Internal current sense voltage divider reference set for output OC sense.
 * @brief OC_ADJ_SET options.
 */
#define OC_ADJ_SET_0_060V   0x0
#define OC_ADJ_SET_0_068V   0x1
#define OC_ADJ_SET_0_076V   0x2
#define OC_ADJ_SET_0_086V   0x3
#define OC_ADJ_SET_0_097V   0x4
#define OC_ADJ_SET_0_109V   0x5
#define OC_ADJ_SET_0_123V   0x6
#define OC_ADJ_SET_0_138V   0x7
#define OC_ADJ_SET_0_155V   0x8
#define OC_ADJ_SET_0_175V   0x9
#define OC_ADJ_SET_0_197V   0xA
#define OC_ADJ_SET_0_222V   0xB
#define OC_ADJ_SET_0_250V   0xC
#define OC_ADJ_SET_0_282V   0xD
#define OC_ADJ_SET_0_317V   0xE
#define OC_ADJ_SET_0_358V   0xF
#define OC_ADJ_SET_0_403V   0x10
#define OC_ADJ_SET_0_454V   0x11
#define OC_ADJ_SET_0_511V   0x12
#define OC_ADJ_SET_0_576V   0x13
#define OC_ADJ_SET_0_648V   0x14
#define OC_ADJ_SET_0_730V   0x15
#define OC_ADJ_SET_0_822V   0x16
#define OC_ADJ_SET_0_926V   0x17
#define OC_ADJ_SET_1_043V   0x18
#define OC_ADJ_SET_1_175V   0x19
#define OC_ADJ_SET_1_324V   0x1A
#define OC_ADJ_SET_1_491V   0x1B
#define OC_ADJ_SET_1_679V   0x1C        //Do not use if PVDD is 6V - 8V
#define OC_ADJ_SET_1_892V   0x1D        //Do not use if PVDD is 6V - 8V
#define OC_ADJ_SET_2_131V   0x1E        //Do not use if PVDD is 6V - 8V
#define OC_ADJ_SET_2_400V   0x1F        //Do not use if PVDD is 6V - 8V


/*~~~~~~~~~~~~~~~~~~~~~~~~~CONTROL REGISTER 2 OPTIONS~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/**
 * @brief CONTROL_REGISTER2 Data bit positions.
 */
typedef struct {

    union {
        unsigned wholeRegister;

        struct {
            unsigned OCTW_SET : 2;
            unsigned GAIN : 2;
            unsigned DC_CAL_CH1 : 1;
            unsigned DC_CAL_CH2 : 1;
            unsigned OC_TOFF : 5;
        };
    };
} DRV8301_CONTROLREGISTER2;

#define OCTW_SET_OCTW       0  //Report both OT and OC at OCTW pin
#define OCTW_SET_OT         1  //Report OT at OCTW pin
#define OCTW_SET_OC         2  //Report OC at OCTW pin

/**
 * Current sense amplifier gain amplification.
 * @brief GAIN options.
 */
#define GAIN_10V            0
#define GAIN_20V            1
#define GAIN_40V            2
#define GAIN_80V            3

/**
 * Shorts input pins of amp1 so that one can calculate dc bias.
 * @brief DC_CAL_CH1 options.
 */
#define DC_CAL_CH1_OFF          0
#define DC_CAL_CH1_ON           1

/**
 * Shorts input pins of amp2 so that one can calculate dc bias.
 * @brief DC_CAL_CH2 options.
 */
#define DC_CAL_CH2_OFF          0
#define DC_CAL_CH2_ON           1

/**
 * @brief OC_TOFF options.
 */
#define OC_TOFF_CBC             0
#define OC_TOFF_OFF_TIME        1

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Methods~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

typedef struct {
    DRV8301_CONTROLREGISTER1 controlRegister1;
    DRV8301_CONTROLREGISTER2 controlRegister2;
    DRV8301_STATUSREGISTER1 statusRegister1;
    DRV8301_STATUSREGISTER2 statusRegister2;
    uint8_t newData;
} DRV8301_Info;

/**
 * @brief Sets up the DRV8301
 * @param DRV8301_Params A pointer to a DRV8301_Info struct which will be updated.
 * @return Returns EXIT_SUCCESS if the device ID response is returned over SPI.
 */
uint8_t DRV8301_Init(DRV8301_Info *drv8301Info);

/**
 * @brief Enable/Disable DC Calibration
 * @return Updates DRV8301_Info with current information and sets newData to 1.
 */
void DRV8301_UpdateStatus(void);

/**
 * @brief Resets the DRV8301 and resets any latched faults.
 */
void DRV8301_Reset(void);

/**
 * @brief Enable/Disable DC Calibration
 * @param enable 1 to enable dc calibration 0 to disable dc calibration.
 */
void DRV8301_DCCalibration(uint8_t enable);

/**
 * @brief Puts the driver board into current sensor calibration mode.
 * @param dcCal One or zero for on and off respectively.
 */
void DRV8301_CurrentSenseCalibration(uint8_t dcCal);

#endif	/* DRV8301_H */

