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
 * @file	SPIdsPIC.c
 * @author 	Pavlo Manovi
 * @date	October, 2013
 * @brief 	This library provides implementation of SPI3 for the PMSM Board v1.6
 *
 * This file provides initialization/read/write implemenation of the SPI3 module
 * on the dsPIC33EP256MC506 and the PMSM board as of v1.6.
 */


#include <xc.h>
#include <stdint.h>
#include <stdlib.h>
#include <spi.h>
#include <pps.h>
#include "SPIdsPIC.h"
#include "PMSMBoard.h"

#define SPI_INTERRUPT

static uint8_t initGuard = 0;
static uint16_t config1, config2, config3;

/**
 * @brief Sets up SPI3 at a rate of 156,250Hz
 * @see spi.h for pound-define significance
 *
 * Note: Only SPI3 is remappable on the dsPIC33EPxxxMC506
 *
 * As of PMSM v1.7 (w/GM306 and SCK2 gw'd to EXT3):
 *      Chip Select = RPI121/RG9
 *      MOSI = RP118
 *      MISO = RP47
 *      SCLK = RP54 (Greenwire fix to EXT3)
 */
uint8_t SPI3_Init(void)
{
	//Make sure init only gets called once.
	if (initGuard == 1) {
		return(EXIT_FAILURE);
	}
	CloseSPI3();

	config1 = ENABLE_SCK_PIN & ENABLE_SDO_PIN &
		SPI_MODE16_ON & SPI_SMP_OFF &
		SPI_CKE_OFF & SLAVE_ENABLE_OFF &
		MASTER_ENABLE_ON & CLK_POL_ACTIVE_LOW &
		SEC_PRESCAL_7_1 & PRI_PRESCAL_64_1;

	config2 = FRAME_ENABLE_OFF & FRAME_SYNC_OUTPUT;

	config3 = SPI_ENABLE & SPI_IDLE_CON & SPI_RX_OVFLOW_CLR;

#ifdef SPI_INTERRUPT
	ConfigIntSPI3(SPI_INT_EN & SPI_INT_PRI_6);
#endif

	//Unlock PPS Registers
	__builtin_write_OSCCONL(OSCCON & ~(1 << 6));

	//Set up PPS
#ifdef __33EP512GM306_H

	//RPOR6bits.RP55R = 0x0021;
	RPINR29bits.SDI3R = 47;
	RPOR10bits.RP118R = 0x001F;
	RPOR6bits.RP54R = 0x0020;

#elif __33EP256MU806_H
	//PPS for MU806 goes here.
#endif

	//Lock PPS Registers
	__builtin_write_OSCCONL(OSCCON | (1 << 6));

	OpenSPI3(config1, config2, config3);

	initGuard = 1;
	return(EXIT_SUCCESS);
}

/**
 * @brief Writes 11 bits of data, to a 4 bit address.
 * @param deviceRegister 4 bit address
 * @param data 11 bits of data to be written to an address
 * @return data word response
 */
uint16_t SPI3_WriteToReg(uint16_t deviceRegister, uint16_t data)
{
	CS = 0;
	WriteSPI3(deviceRegister << 11 | data);
	while (SPI3STATbits.SPITBF);
	CS = 1;
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	CS = 0;
	WriteSPI3(0);
	while (SPI3STATbits.SPITBF);
	CS = 1;
	return(ReadSPI3());
}

/**
 * @brief Reads the 11 bit register data at a 4 bit address
 * @param deviceRegister 4 bit address
 * @return data word response
 */
uint16_t SPI3_ReadFromReg(uint16_t deviceRegister)
{
	CS = 0;
	WriteSPI3(0x8000 | (deviceRegister << 11));
	while (SPI3STATbits.SPITBF);
	CS = 1;
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	Nop();
	CS = 0;
	WriteSPI3(0);
	while (SPI3STATbits.SPITBF);
	CS = 1;
	return(ReadSPI3());
}

#ifdef SPI_INTERRUPT

void __attribute__((__interrupt__, no_auto_psv)) _SPI3Interrupt(void)
{
	//Handles overflows.
	IFS5bits.SPI3IF = 0;
	SPI3STATbits.SPIROV = 0; // Clear SPI3 receive overflow flag if set

}
#endif
