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
 * @file	SPIdsPIC.h
 * @author 	Pavlo Manovi
 * @date	October, 2013
 * @brief 	This library provides methods for SPI2 on the PMSM Board v1.6
 *
 * This file provides initialization/read/write methods for the SPI2 module
 * on the dsPIC33EP256MC506 and the PMSM board as of v1.6. *
 */


#ifndef SPIDSPIC_H
#define	SPIDSPIC_H

#include <stdint.h>

#define F_PB       50000000L
#define USED_I2C    I2C1

/**
 * @brief Sets up SPI2 at a rate of 156,250Hz
 * @see spi.h for pound-define significance
 *
 * Note: Only SPI2 is remappable on the dsPIC33EPxxxMC506
 *
 * As of PMSM v1.6:
 *	Chip Select = RP56/RC8
 *	MOSI = RP55
 *	MISO = RP54
 *	SCLK = RP41
 */
uint8_t SPI1_Init(void);

/**
 * @brief Writes 11 bits of data, to a 4 bit address.
 * @param deviceRegister 4 bit address
 * @param data 11 bits of data to be written to an address
 * @return data word response
 */
uint16_t SPI1_WriteToReg(uint16_t deviceRegister, uint16_t data);

/**
 * @brief Reads the 11 bit register data at a 4 bit address
 * @param deviceRegister 4 bit address
 * @return data word response
 */
uint16_t SPI1_ReadFromReg(uint16_t deviceRegister);

#endif	/* SPIDSPIC_H */

