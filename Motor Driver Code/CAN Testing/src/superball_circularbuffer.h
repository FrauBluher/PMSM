/*
 * Copyright Bar Smith, Bryant Mairs 2012
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses.
 */

/**
 * @file   CircularBuffer.h
 * @author Bar Smith
 * @author Bryant Mairs
 * @date   August, 2012
 * @brief  Provides a circular buffer implementation for bytes and non-primitive datatypes.
 *
 * This circular buffer provides a single buffer interface for almost any situation necessary. It
 * has been written for use with the dsPIC33f, but has been tested on x86.
 *
 * Unit testing has been completed on x86 by compiling with the UNIT_TEST_CIRCULAR_BUFFER macro.
 * With gcc: `gcc CircularBuffer.c -DUNIT_TEST_CIRCULAR_BUFFER`
 */
#ifndef _CIRCULAR_BUFFER_H_
#define _CIRCULAR_BUFFER_H_
// Error codes for use as fucntion return values.
#include <stdint.h>
enum {
    SIZE_ERROR = -1,        // Return value for an error when used with an output that is normally >= 0.
    STANDARD_ERROR = 0, // Return value for an error. Semanticaly a little more clear than `false`
    SUCCESS = 1          // Return value for a successful function call.
};


/**
 * @brief A structure which holds information about the circular buffer.
 *
 * This struct contains all of the metadata necessary to implemented a circular buffer using the
 * memory space pointed to by `data`.
 *
 * The useful properties are dataSize and overflowCount. Most of the other properties you probably
 * don't care about and shouldn't touch.
 */
typedef struct {
	uint16_t readIndex;    //!< Holds the index of the tail of the list. Always points to valid data when empty is false.
	uint16_t writeIndex;   //!< Holds the index of the head of the list. Always points to empty space except when buffer is full.
	uint16_t staticSize;   //!< Stores the static size of the buffer. The actual number of data bytes stored can be retrieved by CB_LENGTH() or CB_GetLength().
	uint16_t dataSize;     //!< The actual number of unread bytes in the buffer.
	uint8_t overflowCount; //!< Tracks how many bytes have been attempted to be written while the buffer was full.
	uint8_t *data;         //!< A pointer to the actual data managed by this buffer.
} CircularBuffer;

/**
 * @brief CB_Init initializes the buffer.
 *
 * Initializes the passed CircularBuffer to the proper values. If either buffer pointer is NULL or
 * null or the size is <= 1 this function returns STANDARD_ERROR, otherwise SUCCESS is returned.
 *
 * This function is idempotent and can also be used to re-initialize a CircularBuffer struct. This
 * will effectively reset a buffer is used with the original buffer pointer and size. Otherwise it
 * can change a buffer to use another buffer pointer and size.
 *
 * @param b A pointer to a circular buffer struct
 * @param data A pointer to where the data will be stored.
 * @param size The length of the buffer.
 */
int CB_Init(CircularBuffer *b, uint8_t *data, const uint16_t size);

/**
 * @brief CB_ReadByte() reads a byte from the buffer.
 *
 * CB_ReadByte() is the inverse of CB_WriteByte(), it reads a single value from `b` and stores it in
 * data. It returns STANDARD_ERROR if b was NULL or had no data to return.
 *
 * @see CB_ReadMany()
 *
 * @param b A pointer to the CircularBuffer struct.
 * @param outData A pointer to where the value will be saved.
 */
int CB_ReadByte(CircularBuffer *b, uint8_t *outData);

/**
 * @brief CB_ReadMany() reads multiple bytes from the buffer.
 *
 * CB_ReadMany reads the top size number of bytes from the buffer `b` to the memory pointed to by
 * `data`. If there are not `size` number of elements currently in the buffer the function will
 * write nothing to memory, remove nothing from the buffer, and return STANDARD_ERROR. If all
 * elements are successfully removed from the buffer the function will return SUCCESS. CB_ReadMany
 * can work easily with any non-primitives.
 *
 * Example use with an array:
 * unsigned char readresults[30];
 * CB_ReadMany(&b, readresults, 30);
 *
 * Example use with a struct:
 * struct d {
 *   unsigned char c;
 *   int64 a;
 * } myStruct;
 * CircularBuffer b;
 * CB_ReadMany(&b, &myStruct, sizeof(d));
 *
 * @see CB_ReadByte()
 *
 * @param b A pointer to the CircularBuffer struct.
 * @param outData A pointer to where the data will be stored.
 * @param size The number of bytes to be read.
 */
int CB_ReadMany(CircularBuffer *b, void *outData, uint16_t size);

/**
 * @brief CB_WriteByte writes a byte into the buffer.
 *
 * CB_WriteByte() writes the new uint8_t data into CircularBuffer b. SUCCESS is
 * returned if that value was successfully added. STANDARD_ERROR is returned if
 * the buffer overflows or b was NULL. If the buffer overflows the new item is
 * not inserted.
 *
 * @param b A pointer to the CircularBuffer struct.
 * @param outData The value to be written to the buffer.
 *
 * @see CB_WriteMany()
 */
int CB_WriteByte(CircularBuffer *b, uint8_t outData);

/**
 * @brief CB_WriteMany() writes multiple bytes into the buffer.
 *
 * CB_WriteMany() writes the first `size` number of elements from the array `data` to the
 * CircularBuffer b. If the boolean value failEarly is true the function will return STANDARD_ERROR
 * if there is not enough space in the buffer.  If `failEarly` is false then as many elements as
 * will fit will be written to the buffer.  When the buffer is full the function will do nothing and
 * return STANDARD_ERROR.
 *
 * CB_WriteMany can also be used to write structures to the buffer.  When writing structures it is
 * recommended that failEarly be set to true so that partial structures won't be written.
 *
 * @param b A pointer to the CircularBuffer struct.
 * @param data A pointer to the data to be written to the buffer.
 * @param size The number of bytes to be written.
 * @param failEarly A flag to switch failure modes.
 */
int CB_WriteMany(CircularBuffer *b, const void *inData, uint16_t size, uint8_t failEarly);

/**
 * @brief CB_Peek retrieves a byte from the buffer without removing it.
 *
 * CB_Peek reads the top element from the buffer `b` and writes it to `data`.  If the
 * buffer is empty or the pointer to buffer is void the function returns STANDARD_ERROR. When
 * the function succeeds it returns SUCCESS.
 *
 * The only difference between this function and CB_ReadByte() is that CB_ReadByte() removes the
 * elements from the buffer as it reads them, while this does not. This function is idempotent.
 *
 * @param b A pointer to the CircularBuffer struct.
 * @param outData A pointer to the byte that will be recorded
 */
int CB_Peek(const CircularBuffer *b, uint8_t *outData);

/**
 * @brief CB_PeekMany() copies the top size number of elements to the array pointed to by data
 *
 * CB_PeekMany() is an extension of Peek() to multi-byte data structures. Given a desired number of
 * bytes, CB_PeekMany() will copy those bytes into the passed byte-array. If there aren't enough bytes
 * in the buffer, then STANDARD_ERROR is returned. This is also the case if the CircularBuffer
 * pointer is NULL. CB_PeakMany can also be used to peak a structure off the buffer.
 *
 * Example use with a struct:
 * ```
 * CircularBuffer b;
 * // Code that puts data in the buffer.
 * struct d {
 *   unsigned char c;
 *   int64 a;
 * } myStruct;
 * CB_PeekMany(&b, &myStruct, sizeof(d));
 * ```
 *
 * @see CB_Peek()
 *
 * @param b A pointer to the CircularBuffer struct.
 * @param outData A pointer to where the data will be stored.
 * @param size The number of bytes to peek.
 */
int CB_PeekMany(const CircularBuffer *b, void *outData, uint16_t size);

/**
 * @brief CB_Remove Removes data from the buffer.
 *
 * The function CB_Remove removes size number of items from the passed in circular buffer.
 * b is a pointer to the CircularBuffer struct and size is the number of elements to be removed.
 * If there are not size elements currently in the buffer, the buffer is emptied. The function
 * will always return SUCCESS.
 *
 * This function is useful for removing data that has already been CB_Peek()d at. An example is with
 * the ECAN peripheral on the dsPICs where I CB_PeekMany() off entire CAN message structs:
 * ```
 * tCanMessage cmsg;
 * CB_PeekMany(&b, &cmsg, sizeof(tCanMessage));
 * Ecan1Transmit(&cmsg);
 * ```
 *
 * Then when the interrupt triggers, which happens only after a successful transmission do I remove
 * the data:
 * ```
 * interrupt() {
 *   CB_Remove(&b, sizeof(tCanMessage));
 * }
 * ```
 *
 * @see CB_Peek()
 * @see CB_PeekMany()
 *
 * @param b A pointer to the circularbuffer structure.
 * @param size The number of elements to be removed from the buffer.
 */
int CB_Remove(CircularBuffer *b, uint16_t size);


#endif /* _CIRCULAR_BUFFER_H_ */
