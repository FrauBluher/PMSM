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
 * @brief 	Provides methods for controlling PMSM motors with dsPIC 33F/E's
 * 
 * This library provides methods for controlling torque, position, and air
 * gap flux linkages of permemant magnet synchronous motors, sinusoidally.  It has
 * been written for use with the dsPIC33F/E on DRV8302 based controllers, specifically
 * the PMSM board available on pavlo.me.
 * 
 * With these methods it is possible to implement a controller wrapping position,
 * speed, or torque into any control schema.
 *
 * If being used with the CAN enabled PMSM Board obtained at either pavlo.me or off of
 * http://github.com/FrauBluher/ as of v 1.4 the following pins are reserved on the
 * dsPIC33EP256MC506:
 *
 * -    PIN FUNCTIONS   -  PIN #  -  USAGE
 * - RPI44/PWM2H/RB12   - Pin 62  -  PWM2
 * - RP42/PWM3H/RB10    - Pin 60  -  PWM3
 * - RP97/RF1           - PIN 59  -  CANTX (VIA PPS)
 * - RPI96/RF0          - PIN 58  -  CANRX (VIA PPS)
 * - RD6                - PIN 54  -  PWRGD
 * - RD5                - PIN 53  -  OCTW
 * - RP56/RC8           - PIN 52  -  FAULT
 * - RP55/RC7           - PIN 51  -  GAIN
 * - RP54/RC6           - PIN 50  -  EN_GATE
 * - TMS/ASDA1/RP41/RB9 - PIN 49  -  DC_CAL
 * - TP40/T4CK/ACL1/RB8 - PIN 48  -  LED1
 * - RC13               - PIN 47  -  LED2
 * - RP39/INT0/RB7      - PIN 46  -  LED3
 * - RPI58/RC10         - PIN 45  -  LED4
 * - PGEC2/RP38/RB6     - PIN 44  -  PGC
 * - PGED2/RP37/RB5     - PIN 43  -  PGD
 * - SDA1/RPI52/RC4     - PIN 36  -  EN_A
 * - SCK1/RPI51/RC3     - PIN 35  -  EN_B
 * - SDI1/RPI25/RA9     - PIN 34  -  EN_C
 * - RPI46/PWM1H/RB14   - PIN 2   -  PWM1
 * - AN0/OA2OUT/RA0     - PIN 13  -  CRNT1 (Current Sens)
 * - AN1/C2IN1+/RA1     - PIN 14  -  CRNT2 (Current Sens)
 *
 *
 * Pins connected to solderjumpers allow for specific ID's to be set on a CAN network with
 * one unified compiled image on multiple PMSM boards. (2^5 Unique ID's)
 *
 * - Digital Pin -  SJ
 * - RB15        -  SJ1
 * - RG6         -  SJ4
 * - RG7         -  SJ5
 * - RG8         -  SJ6
 * - RG9         -  SJ7
 * 
 *
 * The following pins and peripherals are available on headers JP1, JP2, and JP5:
 *
 * -           PIN FUNCTIONS         -  PIN #  -  HEADER,#
 * - AN10/RPI28/RA12                 - PIN 11  -  JP5,2
 * - AN8/RPI27/RA11                  - PIN 12  -  JP5,3
 * - AN4/RPI34/RB2	                 - PIN 17  -  JP5,4
 * - AN5/RP35/RB3 	                 - PIN 18  -  JP5,5
 *
 * - AN3/OA1OUT/RPI33/STED1/RB1      - PIN 16  -  JP2,2
 * - AN6/OA3OUT/C4IN1+/OCFB/RC0      - PIN 21  -  JP2,3
 * - AN7/C3IN1-/C4IN1+/RC1           - PIN 22  -  JP2,4
 * - AN8/C3IN1+/Y1RTS/BCLK1/FLT3/RC2 - PIN 23  -  JP2,5
 *
 * - AN12/C2IN2-/U2RTS/BCLK2/RE12    - PIN 27  -  JP1,1
 * - AN13/C3IN20/U2CTS/RE13          - PIN 28  -  JP1,2
 * - AN14/RPI94/RE14                 - PIN 29  -  JP1,3
 * - AN14/RPI95/RE15                 - PIN 30  -  JP1,4
 * - SDA2/RPI24/RA8                  - PIN 31  -  JP1,5
 * - FLT32/SCL2/RPI36/RB4            - PIN 32  -  JP1,6
 *
 * --Note: RPIx pins can only be remapped to be a peripheral input, while RPx function as I/O.
 *
 */

#ifndef PMSM_H
#define PMSM_H

#include <stdint.h>

#if defined(__dsPIC33FJ128MC802__)
#define FCY 40000000
#warning The 33F PMSM implementation is unsupported at this time.
#endif
#if defined(__dsPIC33EP256MC506__)
#define FCY 60000000
#endif

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
    uint16_t encoderCount;
	uint8_t overtemp;
	uint16_t crrnt1;
    uint16_t crrnt2;
	uint8_t newData;
    uint8_t hallA;
    uint8_t hallB;
    uint8_t hallC;
    uint8_t fault;
} MotorInfo;

/**
 * @brief PMSM initialization call. Sets up hardware and timers.
 * @param *information a pointer to the MotorInfo struct that will be updated.
 * @param mode What kind of control scheme will be used.
 * @param differentialEncoder Does the encoder use differential signals?
 * @return Returns 1 if successful, returns 0 otherwise.
 *
 *  Change the mode value to the following values to
 *  define what kind of controller you want to implement.
 *
 *  Open Loop PMSM                  = 0
 *  Closed Loop PMSM w/Halls	    = 1
 *  Closed Loop PMSM w/Op. Encoder  = 2
 *  Sensorless PMSM FOC BEMF        = 3
 *
 * If using an encoder which uses differential signaling set differentialEncoder to one
 * or zero otherwise.
 *
 * This needs to be called before any other hardware peripheral is initialized.
 * The passed MotorInfo struct will be updated at 100 Hz and the newData flag will be
 * set to 1 when it has been updated.  It is up to you to set newData to zero.  Setting
 * newData to zero isn't required and is provided only for implementation purposes.
 * 
 * PMSM_Init uses Timer2 and sets up the processor.
 */
uint8_t PMSM_Init(MotorInfo *information, uint8_t mode, uint8_t differentialEncoder);

/**
 * @brief Sets the commanded position of the motor.
 * @param pos The position of the rotor in radians from 0 - 2pi / n-poles.
 * 
 * This will set the position of the rotor to the commanded angle divided by the number
 * of poles in the motor divided by three.  If the motor has six poles, it will take two
 * commanded rotations from zero to 2*pi radians to complete one full rotation of the rotor.
 * The passed value will be updated at 100Hz.
 */
void SetPosition(float pos);

/**
 * @brief Sets the commanded torque of the motor.
 * @param power Percentage of torque requested from 0 - 100%.
 * 
 * Scales the pulse-width-modulation duty cycles output from the PMSM algorithm
 * by zero to 100% of generated.  Torque is continuous throughout the rotation of
 * the motor.
 * The passed value will be updated at 100Hz.
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
 * The passed value will be updated at 100Hz.
 */
void SetAirGapFluxLinkage(float Id);

/**
 * @brief Allows for you to turn the half bridges to high-impedance mode.
 * @param gateEnable One or zero for on and off.
 */
void GateControl(uint8_t gateEnable);

/**
 * @brief Puts the driver board into current sensor calibration mode.
 * @param dcCal One or zero for on and off respectively.
 *
 * When DC calibration is enabled, the zero current reading is output from the driver board
 * with every gate driver or noise creating hardware disabled.  This allows for ADC 
 * and offset parameter calibration.
 */
void CurrentSenseCalibration(uint8_t dcCal);

#endif    /*PMSM_H  */