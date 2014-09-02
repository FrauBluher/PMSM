#ifndef UART2_H
#define UART2_H

// USAGE:
// Add Uart2Init() to an initialization sequence called once on startup.
// Use Uart2Write*Data() to push appropriately-sized data chunks into the queue and begin transmission.
// Use Uart2ReadByte() to read bytes out of the buffer

#include <stddef.h>
#include <stdint.h>

#include "CircularBuffer.h"

/**
 * Initializes the UART2 peripheral according to the BRG SFR value passed to it.
 * @param brgRegister The value to be placed in the BRG register.
 */
void Uart2Init(uint16_t brgRegister);

/**
 * Alters the baud rate of the UART2 peripheral to that dictated by brgRegister.
 * @param brgRegister The new baud rate.
 */
void Uart2ChangeBaudRate(uint16_t brgRegister);

/**
 * This function reads a byte out of the received data buffer for UART2.
 * @param datum The data received from the buffer. If no data was there it's unmodified.
 * @return A boolean value of whether valid data was returned.
 */
int Uart2ReadByte(uint8_t *datum);

/**
 * This function starts a transmission sequence after enqueuing a single byte into
 * the buffer.
 */
void Uart2WriteByte(uint8_t datum);

/**
 * This function augments the Uart2WriteByte() function by providing an interface
 * that enqueues multiple bytes.
 */
int Uart2WriteData(const void *data, size_t length);

#endif // UART2_H
