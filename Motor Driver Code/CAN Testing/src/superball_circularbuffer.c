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
 * @file   CircularBuffer.c
 * @author Bar Smith
 * @author Bryant Mairs
 * @date   August, 2012
 * @brief  Provides a circular buffer implementation for bytes and non-primitive datatypes.
 *
 * This circular buffer provides a single buffer interface for almost any situation necessary. It
 * has been written for use with the dsPIC33f, but has been tested on x86.
 *
 * Unit testing has been completed on x86 by compiling with the UNIT_TEST_CIRCULAR_BUFFER macro.
 * With gcc: `gcc CircularBuffer.c -DUNIT_TEST_CIRCULAR_BUFFER -Wall`
 */
#include "superball_circularbuffer.h"

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

int CB_Init(CircularBuffer *b, uint8_t *buffer, const uint16_t size)
{
	// Check the validity of pointers.
	if (!buffer || !b) {
		return STANDARD_ERROR;
	}

	// Checks that the size is valid.
	if (size <= 1) {
		return STANDARD_ERROR;
	}

	// Store the buffer pointer and initialize it all to zero.
	// This is not necessary, but makes debugging easier.
	b->data = buffer;
	uint16_t i;
	for (i = 0; i < size; ++i) {
		b->data[i] = 0;
	}

	// Initialize all variables. The only one of note is `empty`, which is initialized to true.
	b->readIndex = 0;
	b->writeIndex = 0;
	b->staticSize = size;
	b->dataSize = 0;
	b->overflowCount = 0;

	return SUCCESS;
}

int CB_ReadByte(CircularBuffer *b, uint8_t *outData)
{
	if (b) {
		if (b->dataSize) {
			//copys the last element from the buffer to data
			*outData = b->data[b->readIndex];
			//sets the buffer empty if there was only one element in it
			if (b->dataSize == 1) {
				//checks for wrap around
				b->readIndex = b->readIndex < (b->staticSize - 1)?b->readIndex + 1:0;
			} else {
				//checks for wrap around and moves indicies
				b->readIndex = b->readIndex < (b->staticSize - 1)?b->readIndex + 1:0;
			}
			--b->dataSize;
			return SUCCESS;
		}
	}
	return STANDARD_ERROR;
}

int CB_ReadMany(CircularBuffer *b, void *outData, uint16_t size)
{
	int16_t i;
	if (b && outData) {
		//cast data so that it can be used to ready bytes
		uint8_t *data_u = (uint8_t*)outData;
		//check if there are enough items in the buffer to read
		if (b->dataSize >= size) {

			// And read the data.
			for (i = 0; i < size; ++i) {
				data_u[i] = b->data[b->readIndex];

				// Update the readIndex taking into account wrap-around.
				if (b->readIndex < b->staticSize - 1) {
					++b->readIndex;
				} else {
					b->readIndex = 0;
				}
			}
			b->dataSize -= size;
			return SUCCESS;
		}
	}
	return STANDARD_ERROR;
}

int CB_WriteByte(CircularBuffer *b, uint8_t inData)
{
	if (b) {
		// If the buffer is full the overflow count is incremented and no data is written.
		if (b->dataSize == b->staticSize) {
			++b->overflowCount;
			return STANDARD_ERROR;
		} else {
			b->data[b->writeIndex] = inData;
			// Now update the writeIndex taking into account wrap-around.
			if (b->dataSize) {
				b->writeIndex = b->writeIndex < (b->staticSize - 1) ? b->writeIndex + 1: 0;
			} else {
				b->writeIndex = b->writeIndex < (b->staticSize - 1) ? b->writeIndex + 1: 0;
			}
			++b->dataSize;
			return SUCCESS;
		}
	}
	return STANDARD_ERROR;
}

int CB_WriteMany(CircularBuffer *b, const void *inData, uint16_t size, uint8_t failEarly)
{
	if (b && inData) {
		uint8_t *data_u = (uint8_t*)inData;
		//if the fail early value is set
		if (failEarly) {
			//Checks to make sure there is enough space
			if (b->staticSize - b->dataSize < size) {
				return STANDARD_ERROR;
			} else {
				int i = 0;
				//runs size times
				while (i < size) {
					//writes to the buffer
					b->data[b->writeIndex] = data_u[i];
					++i;
					//checks for wrap around and moves the indicies
					b->writeIndex = b->writeIndex < (b->staticSize - 1) ? b->writeIndex + 1: 0;
				}
				b->dataSize += i;
				return SUCCESS;
			}
		}
		// Otherwise we try and write as much data as we can.
		else {
			int i = 0;
			while (i < size) {
				//if the buffer is full the overflow count is increased and STANDARD_ERROR is returned
				if (b->dataSize == b->staticSize) {
					b->overflowCount += (size - i);
					return STANDARD_ERROR;
				}
				//reads an element from the buffer to data
				b->data[b->writeIndex] = data_u[i];
				++i;
				++b->dataSize;
				//move the indicies and check for wrap around
				b->writeIndex = (b->writeIndex < (b->staticSize - 1)) ? b->writeIndex + 1: 0;
			}
			return SUCCESS;
		}
	}
	return STANDARD_ERROR;
}

int CB_Peek(const CircularBuffer *b, uint8_t *outData)
{
	if (b) {
		if (b->dataSize > 0) {
			*outData = b->data[b->readIndex];
			return SUCCESS;
		}
	}
	return STANDARD_ERROR;
}

int CB_PeekMany (const CircularBuffer *b, void *outData, uint16_t size)
{
	uint16_t i;
	int tmpHead;

	if (b) {
		uint8_t *data_u = (uint8_t*)outData;
		// Make sure there's enough data to read off and read them off one-by-one.
		if (b->dataSize >= size) {
			tmpHead = b->readIndex;
			for (i = 0; i < size; ++i) {
				data_u[i] = b->data[tmpHead];

				// Handle wrapping around the buffer.
				if (tmpHead < b->staticSize - 1) {
					++tmpHead;
				} else {
					tmpHead = 0;
				}
			}
			return SUCCESS;
		}
	}
	return STANDARD_ERROR;
}

int CB_Remove(CircularBuffer *b, uint16_t size){
	// If there are more elements in the buffer.
	if (b->dataSize >= size) {
		// Checks to see if the buffer will wrap around.
		if ((b->staticSize - b->readIndex) < size) {
			b-> readIndex = size - (b->staticSize - b->readIndex);
		} else {
			// If the buffer will not wrap around size is added to read index.
			b->readIndex = b->readIndex + size;
		}
		b->dataSize -= size;
		return SUCCESS;
	}
	// If one is trying to remove more elements than are in the buffer, the buffer is made empty.
	else {
		b->readIndex = b->writeIndex;
		b->dataSize = 0;
		return SUCCESS;
	}
}

/**
 * This begins the unit testing code. Directions for compilation are at the top of the header file.
 */
#ifdef UNIT_TEST_CIRCULAR_BUFFER

#include <string.h>
#include <stdio.h>
#include <assert.h>

/**
 * @brief A struct used for testing.
 */
typedef struct {
	uint8_t hey;
	int foo;
	float bar;
} TestStruct;

/**
 * @brief Returns whether two circular buffers are equal in their metadata.
 *
 * This does not do an exact comparison of their data arrays, just their metadata.
 */
int TestStructEqual(const TestStruct *a, const TestStruct *b)
{
	return (a->hey == b->hey &&
	        a->foo == b->foo &&
	        a->bar == b->bar);
}

/**
 * @brief Run various unit tests confirming proper operation of the CircularBuffer.
 *
 * To run (assuming all files in the same directory and that's your current directory):
 * ```
 * $ gcc CircularBuffer.c -DUNIT_TEST_CIRCULAR_BUFFER
 * $ a.out
 * Running unit tests.
 * All tests passed.
 * $
 */
int main()
{
	printf("Running unit tests.\n");

	// These tests check the ability of the circular buffer to write a single item and
	// then read it back.
	{
		// Create a new circular buffer.
		CircularBuffer b;
		uint16_t size = 256;
		uint8_t *buffer = (uint8_t*)malloc(256*sizeof(uint8_t));
		CB_Init(&b, buffer, size);
		assert(!b.dataSize);

		// Add a single item and check.
		CB_WriteByte(&b, 0x56);
		assert(b.dataSize == 1);
		uint8_t peekval;
		assert(CB_Peek(&b, &peekval));
		assert(peekval == 0x56);


		// Remove that item and check.
		uint8_t d;
		assert(CB_ReadByte(&b, &d) && d == 0x56);
		assert(b.dataSize == 0);
		assert(CB_Peek(&b, &peekval) == 0);

		free(buffer);
	}

	/* This tests the ability of the buffer to read and write many items. This code also tests
	writing two and reading from a buffer which has been wrapped around. Deeppeek is tested.
	*/
	{
		// Create a new circular buffer.
		CircularBuffer b;
		uint16_t size = 256;
		uint8_t *buffer = (uint8_t*)malloc(256*sizeof(uint8_t));
		CB_Init(&b, buffer, size);
		assert(!b.dataSize);

		// Here we make a 1016 int8_t long string for testing. Testing with the library with BUFFER_SIZE
		// set to larger than 1016 will produce errors.
		int8_t testString[] = "Copyright (C) <year> <copyright holders> Permission is hereby granted, free of int8_tge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THEAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.";
		// Fill the buffer to SIZE+1 and check.
		uint16_t i;
		for (i = 0; i < b.staticSize; ++i) {
			assert(b.dataSize == i);
			assert(CB_WriteByte(&b, testString[i]));
			assert(b.dataSize == i + 1);
		}
		assert(!CB_WriteByte(&b, 0x89));
		assert(b.overflowCount == 1);


		// Run a deepPeek on the now-full buffer.
		uint8_t tmpString[b.staticSize];
		assert(CB_PeekMany(&b, tmpString, b.staticSize));
		assert(b.dataSize == b.staticSize);


		i = 0;
		while(i < 256){
			++i;
		}
		assert(memcmp(testString, tmpString, b.staticSize) == 0);
		assert(b.dataSize);

		// Verify reading of an entire circular-buffer
		uint8_t d;
		i = b.dataSize;
		while (i > 0) {
			assert(CB_ReadByte(&b, &d));
			assert(d == testString[b.staticSize - i]);
			i--;
		}
		assert(b.dataSize == 0);
		d = 0x77;
		int8_t d2 = d;
		assert(!CB_ReadByte(&b, &d));
		assert(d == d2); //nothing has been read

		// Test element insertion when the buffer wraps around.
		uint8_t peekval;
		assert(CB_WriteByte(&b, 91));
		assert(b.overflowCount == 1); // Overflow is triggered on an earlier test
		assert(b.dataSize == 1);
		CB_Peek(&b, &peekval);
		assert(peekval == 91);
		assert(CB_WriteByte(&b, 92));
		assert(b.dataSize == 2);
		assert(CB_WriteByte(&b, 93));
		assert(b.dataSize == 3);
		assert(CB_WriteByte(&b, 94));
		assert(b.dataSize == 4);

		// Test DeepPeek on wrapped-around buffers
		uint8_t peekData[4];
		assert(CB_PeekMany(&b, peekData, 4));
		assert(peekData[0] == 91);
		assert(peekData[1] == 92);
		assert(peekData[2] == 93);
		assert(peekData[3] == 94);

		// Test reading now.
		assert(CB_ReadByte(&b, &d) && d == 91);
		assert(CB_ReadByte(&b, &d) && d == 92);
		assert(CB_ReadByte(&b, &d) && d == 93);
		assert(CB_ReadByte(&b, &d) && d == 94);
		assert(!CB_ReadByte(&b, &d) && d == 94);

		free(buffer);
	}

	/* This section of test code checks that CB_Init will not initialize a buffer if its
	arguments are not valid.
	*/
	{

		//Test initialization with invalid arguments
		CircularBuffer b;
		uint8_t *buffer = (uint8_t*)malloc(256*sizeof(uint8_t));
		assert(CB_Init(&b, buffer, 0) == STANDARD_ERROR); //checks the invalid argument size = 0
		assert(CB_Init(&b, buffer, 1) == STANDARD_ERROR); //checks the invalid argument size = 1
		assert(CB_Init(&b, buffer, 128) == SUCCESS); //checks that the function returns SUCCESS upon success
		buffer = NULL;
		assert(CB_Init(&b, buffer, 16) == STANDARD_ERROR); //tests the invalid argument where buffer is a null pointer

		free(buffer);
	}

	/* This code tests the buffer at the edge case size is two.
	*/
	{
		//Test functionality at edge case size is 2
		uint8_t CBtestbuf[2];
		CircularBuffer b;
		CB_Init(&b, CBtestbuf, 2);  //creates a new buffer of length two
		assert(!b.dataSize);

		// Add a single item and check.
		uint8_t peekval;
		CB_WriteByte(&b, 0x56);
		assert(b.dataSize == 1);
		CB_Peek(&b, &peekval);
		assert(peekval == 0x56);

		// Remove that item and check.
		uint8_t e;
		assert(CB_ReadByte(&b, &e) && e == 0x56);
		assert(b.dataSize == 0);
		assert(CB_Peek(&b, &peekval) == 0);

		//Now write two characters to the buffer
		assert(CB_WriteByte(&b, 0x56));
		assert(CB_WriteByte(&b, 0x58));
		assert(b.dataSize == 2); //Check to see if the length is correct
		CB_WriteByte(&b, 0x59);  //Write a third element to the two bit buffer
		assert(b.overflowCount == 1); //Check that overflow has occurred
		assert(CB_ReadByte(&b, &e) && e == 0x56); //Check Reading an element
		assert(b.dataSize == 1); //Check the length of the buffer
		assert(CB_ReadByte(&b, &e) && e == 0x58); //Check Reading an element
		assert(b.dataSize == 0); //Check that the buffer is now empty
		assert(CB_ReadByte(&b, &e) == STANDARD_ERROR); //checks that the empty buffer cannot be read from
	}

	/* This code tests the edge case where the buffer is at the maximum size.  The size
	is limited by the maximum value which can be held in a uint16_t.
	*/
	{
		//Test functionality at edge case size is UINT16_MAX
		CircularBuffer b;
		uint8_t *buffertwo = (uint8_t*)malloc(UINT16_MAX*sizeof(uint8_t));

		CB_Init(&b, buffertwo, UINT16_MAX);
		assert(!b.dataSize);
		assert(b.staticSize == UINT16_MAX);


		// Here we use the same UINT16_MAX int8_character long string for testing. Testing with the library with BUFFER_SIZE
		// set to larger than UINT16_MAX will produce errors.
		uint8_t testStringtwo[b.staticSize+1];

		int i;
		for (i = 0; i < b.staticSize; ++i) {
			testStringtwo[i] = i;
		}

		// Fill the buffer to SIZE+1 and check
		for (i = 0; i < b.staticSize; ++i) {
			assert(b.dataSize == i);
			assert(CB_WriteByte(&b, i));
			assert(b.dataSize == i + 1);
		}
		assert(!CB_WriteByte(&b, 0x89));
		assert(b.overflowCount == 1);

		// Run a deepPeek on the now-full buffer.
		uint8_t tmpStringtwo[b.staticSize];
		assert(CB_PeekMany(&b, tmpStringtwo, b.staticSize));
		assert(b.dataSize == b.staticSize);
		assert(memcmp(testStringtwo, tmpStringtwo, b.staticSize) == 0);

		// Verify reading of an entire circular-buffer
		uint8_t d;
		for (i = b.dataSize; i > 0; --i) {
			assert(CB_ReadByte(&b, &d));
			assert(d == testStringtwo[b.staticSize - i]);
		}
		assert(b.dataSize == 0);
		d = 0x77;
		int8_t d3 = d;
		assert(!CB_ReadByte(&b, &d));
		assert(d == d3);
		assert(!b.dataSize);

		// Test element insertion when the buffer wraps around.
		uint8_t peekval;
		assert(CB_WriteByte(&b, 91));
		assert(b.overflowCount == 1); // Overflow is triggered on an earlier test
		assert(b.dataSize == 1);
		CB_Peek(&b, &peekval);
		assert(peekval == 91);
		assert(CB_WriteByte(&b, 92));
		assert(b.dataSize == 2);
		assert(CB_WriteByte(&b, 93));
		assert(b.dataSize == 3);
		assert(CB_WriteByte(&b, 94));
		assert(b.dataSize == 4);

		// Test DeepPeek on wrapped-around buffers
		uint8_t peekDatatwo[4];
		assert(CB_PeekMany(&b, peekDatatwo, 4));
		assert(peekDatatwo[0] == 91);
		assert(peekDatatwo[1] == 92);
		assert(peekDatatwo[2] == 93);
		assert(peekDatatwo[3] == 94);

		// Test reading now.
		assert(CB_ReadByte(&b, &d) && d == 91);
		assert(CB_ReadByte(&b, &d) && d == 92);
		assert(CB_ReadByte(&b, &d) && d == 93);
		assert(CB_ReadByte(&b, &d) && d == 94);
		assert(!CB_ReadByte(&b, &d) && d == 94);

		free(buffertwo);
	}

	/* This tests the remove function
	*/
	{
		/**Test Remove Function*/
		CircularBuffer b;
		uint8_t CBtestbuften[10];
		CB_Init(&b, CBtestbuften, 10);  //creates a new buffer of length ten
		assert(!b.dataSize);

		int i;
		i = 0;
		while(i < 9){
			CB_WriteByte(&b, i);
			++i;
		}
		//Test removing a valid number of items
		assert(b.dataSize == 9);
		assert(CB_Remove(&b, 4));
		assert(b.dataSize == 5);
		uint8_t d;
		CB_ReadByte(&b, &d);
		assert(d == 4);

		//Test removing more items than are in the buffer
		assert(b.dataSize == 4);
		CB_Remove(&b, 10);
		assert(b.dataSize == 0); //The buffer is now empty
	}

	/* This tests using the CB_ReadMany function to read a buffer.
	*/
	{
		/**Test reading multiple values from the buffer using CB_ReadMany */
		CircularBuffer b;
		uint8_t CBtestbufthirty[30];
		CB_Init(&b, CBtestbufthirty, 30);  //creates a new buffer of length thirty
		assert(!b.dataSize);

		int i = 0;
		while(i < 30){
			CB_WriteByte(&b, i);
			++i;
		}
		assert(b.dataSize == 30);

		uint8_t readresults[30];
		assert(CB_ReadMany(&b,readresults, 15));
		i = 0;
		while(i < 15){
			assert(readresults[i] == i);
			++i;
		}
		assert(b.dataSize == 15);
		assert(CB_ReadMany(&b,readresults, 15));
		assert(b.dataSize == 0); //Checks that buffer is now empty
		assert(b.readIndex == b.writeIndex); //checks that the pointers are equal
	}


	/* This tests using CB_WriteMany to write to a buffer.
	*/
	{
		/**Testing the WriteMany function*/
		CircularBuffer b;
		uint8_t CBtestbufthirty[30];
		CB_Init(&b, CBtestbufthirty, 30);  //re-initializes buffer of length thirty
		assert(!b.dataSize);

		uint8_t readresults[100];
		int i = 0;
		while (i < 100) {
			readresults[i] = i;
			++i;
		}
		assert(CB_WriteMany(&b, readresults, 22, true)); //write 22 values from readresults to the buffer
		assert(b.dataSize == 22);

		uint8_t d;
		i = 0;
		while (i < 22) {
			CB_ReadByte(&b, &d);
			assert(d == i);
			++i;
		}

		CB_Init(&b, CBtestbufthirty, 30);  //re-initializes buffer of length thirty
		assert(!b.dataSize);
		assert(b.readIndex == b.writeIndex);
		i = 0;
		while (i < 30) {
			readresults[i] = i;
			++i;
		}
		CB_WriteMany(&b, readresults, 22, false); //write 22 values from readresults to the buffer
		assert(b.dataSize == 22);
		i = 0;
		while (i < 22) {
			CB_ReadByte(&b, &d);
			assert(d == i);
			++i;
		}

		/**Now test the failure criteria specified in failEarly*/
		CB_Init(&b, CBtestbufthirty, 30);  //re-initializes buffer of length thirty
		CB_WriteMany(&b, readresults, 18, true);
		assert(b.dataSize == 18);
		assert(CB_WriteMany(&b, readresults, 50, true) == STANDARD_ERROR); //Writing more than the buffer can hold returns an error
		assert(b.dataSize == 18); // Checks that nothing was written
		assert(!CB_WriteMany(&b, readresults, 100, false)); // Now without the size check
		assert(b.dataSize == 30); //Checks that buffer is now full
		assert(b.overflowCount == 88); //100-(30-18) = 88 elements have overflowed

		i = 0;
		while (i < 18) {
			CB_ReadByte(&b, &d);
			assert(i == d);
			++i;
		}
		while (i < 12) {
			CB_ReadByte(&b, &d);
			assert(i == d);
			++i;
		}
	}

	/* This code tests using the CB_WriteMany and CB_ReadMany functions to read and write
	structures to a buffer.  CB_PeekMany is also tested.
	*/
	{
		// The test circular buffer
		CircularBuffer c;

		//Testing writing of a structure to the buffer and reading it back
		// Create a new circular buffer.
		TestStruct t1 = {6, 42, 1.5};

		uint16_t sizetwo = 256*sizeof(TestStruct);
		uint8_t structbuff[sizetwo];
		assert(CB_Init(&c, structbuff, sizetwo)); //Creates a buffer to hold 256 TestStruct structures
		assert(!c.dataSize);
		CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
		assert(c.dataSize == sizeof(TestStruct));

		TestStruct f;
		CB_ReadMany(&c, &f, sizeof(TestStruct)); //read the structure back from the buffer
		assert(!c.dataSize); //the buffer is now empty
		assert(TestStructEqual(&f, &t1));

		TestStruct t2 = {56, 700, 5.75}; //filled with arbitrary values

		//Write a single structure to the buffer and then read it back
		assert(c.dataSize == 0);
		assert(CB_WriteMany(&c, &t2, sizeof(TestStruct), true));
		assert(c.dataSize == sizeof(TestStruct));

		assert(CB_ReadMany(&c, &f, sizeof(TestStruct))); //read the structure back from the buffer
		assert(TestStructEqual(&f, &t2));

		//Write two structures to the buffer and then read them back
		CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t2, sizeof(TestStruct), true);

		assert(c.dataSize == 2*sizeof(TestStruct));

		CB_ReadMany(&c, &f, sizeof(TestStruct)); //read first the structure back from the buffer
		assert(TestStructEqual(&f, &t1));

		CB_ReadMany(&c, &f, sizeof(TestStruct)); //read the second structure back from the buffer
		assert(TestStructEqual(&f, &t2));

		assert(c.readIndex == c.writeIndex); //The buffer is now empty.

		// Write four structures to the buffer using a loop and read them back.

		CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t2, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t2, sizeof(TestStruct), true);

		assert(c.dataSize == 4*sizeof(TestStruct));

		CB_ReadMany(&c, &f, sizeof(TestStruct)); //read first the structure back from the buffer
		assert(TestStructEqual(&f, &t1));

		assert(c.dataSize == 3*sizeof(TestStruct));

		CB_ReadMany(&c, &f, sizeof(TestStruct)); //read the second structure back from the buffer
		assert(TestStructEqual(&f, &t2));

		assert(c.dataSize == 2*sizeof(TestStruct));

		CB_ReadMany(&c, &f, sizeof(TestStruct)); //read third the structure back from the buffer
		assert(TestStructEqual(&f, &t1));

		assert(c.dataSize == 1*sizeof(TestStruct));

		CB_ReadMany(&c, &f, sizeof(TestStruct)); //read the fourth structure back from the buffer
		assert(TestStructEqual(&f, &t2));

		assert(c.dataSize == 0); //the buffer is now empty

		// Now write six structures and then read them off using a loop.
		CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t2, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t2, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
		CB_WriteMany(&c, &t2, sizeof(TestStruct), true);

		int i = 0;
		while (i < 3) {
			CB_ReadMany(&c, &f, sizeof(TestStruct)); //read first the structure back from the buffer
			assert(TestStructEqual(&f, &t1));

			CB_ReadMany(&c, &f, sizeof(TestStruct)); //read the second structure back from the buffer
			assert(TestStructEqual(&f, &t2));

			++i;
		}

		//Now write from a loop and read from a loop
		i = 0;
		while (i < 3) {
			CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
			CB_WriteMany(&c, &t2, sizeof(TestStruct), true);
			++i;
		}

		i = 0;
		while (i < 3) {
			CB_ReadMany(&c, &f, sizeof(TestStruct)); //read first the structure back from the buffer
			assert(TestStructEqual(&f, &t1));

			CB_ReadMany(&c, &f, sizeof(TestStruct)); //read the second structure back from the buffer
			assert(TestStructEqual(&f, &t2));

			++i;
		}

		assert(c.readIndex == c.writeIndex); //the buffer is empty

		//Now write 40 elements from a loop and read 40 elements from a loop
		i = 0;
		while (i < 20) {
			CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
			CB_WriteMany(&c, &t2, sizeof(TestStruct), true);
			++i;
		}

		i = 0;
		while (i < 20) {
			CB_ReadMany(&c, &f, sizeof(TestStruct)); //read first the structure back from the buffer
			assert(TestStructEqual(&f, &t1));

			CB_ReadMany(&c, &f, sizeof(TestStruct)); //read the second structure back from the buffer
			assert(TestStructEqual(&f, &t2));

			++i;
		}

		//Now try to overfill a buffer and then read the structures back
		//C is length 256*sizeof(TestStruct) so we will try to write 260 structures
		assert(c.readIndex == c.writeIndex); //the buffer is empty
		assert(c.dataSize == 0);

		i = 0;
		while (i < 130) { //writes 260 structures to the buffer
			CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
			CB_WriteMany(&c, &t2, sizeof(TestStruct), true);
			++i;
		}

		i = 0;
		while (i < 128) {
			CB_ReadMany(&c, &f, sizeof(TestStruct)); //read first the structure back from the buffer
			assert(TestStructEqual(&f, &t1));

			CB_ReadMany(&c, &f, sizeof(TestStruct)); //read the second structure back from the buffer
			assert(TestStructEqual(&f, &t2));

			++i;
		}

		assert(c.readIndex == c.writeIndex); //the buffer is empty
		assert(c.dataSize == 0);

		//Testing CB_PeekMany on structures
		TestStruct peekTest;

		CB_WriteMany(&c, &t1, sizeof(TestStruct), true);
		CB_PeekMany(&c, (uint8_t*)&peekTest, sizeof(TestStruct));
		assert(TestStructEqual(&t1, &peekTest));
	}

	printf("All tests passed.\n");

	return 0;

}
#endif // UNIT_TEST_CIRCULAR_BUFFER

