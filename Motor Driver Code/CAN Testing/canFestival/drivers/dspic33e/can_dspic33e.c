/*
This file is part of CanFestival, a library implementing CanOpen Stack.

Copyright (C): Edouard TISSERANT and Francis DUPIN
AVR Port: Andreas GLAUSER and Peter CHRISTEN

See COPYING file for copyrights details.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

//#define DEBUG_WAR_CONSOLE_ON
//#define DEBUG_ERR_CONSOLE_ON

#include "../../include/dspic33e/can_dspic33e.h"
#include "../../include/dspic33e/canfestival.h"
#include "../../../../../Sensor_Board/superball_circularbuffer.h"
#include <ecan.h>
#include <p33Exxxx.h>
#include "../../../../../Sensor_Board/sensor_pindefs.h"

///////////////////////////////////////////////////////////////////////////////
////////////////////// USER FUNCTIONS Replace when this is a library //////////

/******************************************************************************
 * Function:     void Ecan1WriteRxAcptFilter(int16_t n, int32_t identifier,
 *               uint16_t exide,uint16_t bufPnt,uint16_t maskSel)
 *
 * PreCondition:  None
 *
 * Input:         n-> Filter number [0-15]
 *                identifier-> Bit ordering is given below
 *                Filter Identifier (29-bits) :
 *                0b000f ffff ffff ffff ffff ffff ffff ffff
 *                     |____________|_____________________|
 *                        SID10:0          EID17:0
 *
 *               Filter Identifier (11-bits) :
 *               0b0000 0000 0000 0000 0000 0fff ffff ffff
 *                                           |___________|
 *                                             SID10:
 *               exide -> "0" for standard identifier
 *                        "1" for Extended identifier
 *               bufPnt -> Message buffer to store filtered message [0-15]
 *               maskSel -> Optinal Masking of identifier bits [0-3]
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      Configures Acceptance filter "n" for ECAN1.
 *****************************************************************************/
void Ecan1WriteRxAcptFilter(int16_t n, int32_t identifier, uint16_t exide, uint16_t bufPnt, uint16_t maskSel)
{
	uint32_t sid10_0 = 0;

	uint32_t eid15_0 = 0;

	uint32_t eid17_16 = 0;
	uint16_t *sidRegAddr;
	uint16_t *bufPntRegAddr;
	uint16_t *maskSelRegAddr;
	uint16_t *fltEnRegAddr;

	C1CTRL1bits.WIN = 1;

	// Obtain the Address of CiRXFnSID, CiBUFPNTn, CiFMSKSELn and CiFEN register for a given filter number "n"
	sidRegAddr = (uint16_t *) (&C1RXF0SID + (n << 1));
	bufPntRegAddr = (uint16_t *) (&C1BUFPNT1 + (n >> 2));
	maskSelRegAddr = (uint16_t *) (&C1FMSKSEL1 + (n >> 3));
	fltEnRegAddr = (uint16_t *) (&C1FEN1);

	// Bit-filed manupulation to write to Filter identifier register
	if (exide == 1) { // Filter Extended Identifier
		eid15_0 = (identifier & 0xFFFF);
		eid17_16 = (identifier >> 16) & 0x3;
		sid10_0 = (identifier >> 18) & 0x7FF;

		*sidRegAddr = (((sid10_0) << 5) + 0x8) + eid17_16; // Write to CiRXFnSID Register
		*(sidRegAddr + 1) = eid15_0; // Write to CiRXFnEID Register
	} else { // Filter Standard Identifier
		sid10_0 = (identifier & 0x7FF);
		*sidRegAddr = (sid10_0) << 5; // Write to CiRXFnSID Register
		*(sidRegAddr + 1) = 0; // Write to CiRXFnEID Register
	}

	*bufPntRegAddr = (*bufPntRegAddr) & (0xFFFF - (0xF << (4 * (n & 3)))); // clear nibble
	*bufPntRegAddr = ((bufPnt << (4 * (n & 3))) | (*bufPntRegAddr)); // Write to C1BUFPNTn Register
	*maskSelRegAddr = (*maskSelRegAddr) & (0xFFFF - (0x3 << ((n & 7) * 2))); // clear 2 bits
	*maskSelRegAddr = ((maskSel << (2 * (n & 7))) | (*maskSelRegAddr)); // Write to C1FMSKSELn Register
	*fltEnRegAddr = ((0x1 << n) | (*fltEnRegAddr)); // Write to C1FEN1 Register
	C1CTRL1bits.WIN = 0;
}

/******************************************************************************
 * Function:     void Ecan1WriteRxAcptMask(int16_t m, int32_t identifier,
 *               uint16_t mide, uint16_t exide)
 *
 * PreCondition:  None
 *
 * Input:        m-> Mask number [0-2]
		 identifier-> Bit ordering is given below n-> Filter number [0-15]
 *                identifier-> Bit ordering is given below
 *                Filter mask Identifier (29-bits) :
 *                0b000f ffff ffff ffff ffff ffff ffff ffff
 *                     |____________|_____________________|
 *                        SID10:0          EID17:0
 *
 *               Filter mask Identifier (11-bits) :
 *               0b0000 0000 0000 0000 0000 0fff ffff ffff
 *                                           |___________|
 *                                             SID10:
 *               mide ->  "0"  Match either standard or extended address message
 *                             if filters match
 *                        "1"  Match only message types that correpond to
 *                             'exide' bit in filter
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      Configures Acceptance filter "n" for ECAN1.
 *****************************************************************************/
void Ecan1WriteRxAcptMask(int16_t m, int32_t identifier, uint16_t mide, uint16_t exide)
{
	uint32_t sid10_0 = 0;

	uint32_t eid15_0 = 0;

	uint32_t eid17_16 = 0;
	uint16_t *maskRegAddr;

	C1CTRL1bits.WIN = 1;

	// Obtain the Address of CiRXMmSID register for given Mask number "m"
	maskRegAddr = (uint16_t *) (&C1RXM0SID + (m << 1));

	// Bit-filed manupulation to write to Filter Mask register
	if (exide == 1) { // Filter Extended Identifier
		eid15_0 = (identifier & 0xFFFF);
		eid17_16 = (identifier >> 16) & 0x3;
		sid10_0 = (identifier >> 18) & 0x7FF;

		if (mide == 1) {
			*maskRegAddr = ((sid10_0) << 5) + 0x0008 + eid17_16; // Write to CiRXMnSID Register
		} else {
			*maskRegAddr = ((sid10_0) << 5) + eid17_16; // Write to CiRXMnSID Register
		}

		*(maskRegAddr + 1) = eid15_0; // Write to CiRXMnEID Register
	} else { // Filter Standard Identifier
		sid10_0 = (identifier & 0x7FF);
		if (mide == 1) {
			*maskRegAddr = ((sid10_0) << 5) + 0x0008; // Write to CiRXMnSID Register
		} else {
			*maskRegAddr = (sid10_0) << 5; // Write to CiRXMnSID Register
		}

		*(maskRegAddr + 1) = 0; // Write to CiRXMnEID Register
	}

	C1CTRL1bits.WIN = 0;
}
///////////////////////////////////////////////////////////////////////////////
////////////////////// USER FUNCTIONS Replace when this is a library //////////

//internal RX buffer for CAN messages


static unsigned int ecan1RXMsgBuf[8][8] __attribute__((aligned(8 * 16)));
static unsigned int ecan1TXMsgBuf[8][8] __attribute__((aligned(8 * 16)));
//#define CAN_RX_BUF_SIZE 1
//static volatile Message rxbuffer[CAN_RX_BUF_SIZE]; //this is an internal buffer for received messages
//static volatile uint8_t rxbuffer_start;
//static volatile uint8_t rxbuffer_stop;
#define CAN_RX_BUFF_SIZE 5*sizeof(Message)
uint8_t can_rx_buffer_array[CAN_RX_BUFF_SIZE];
CircularBuffer can_rx_circ_buff;
uint8_t txreq_bitarray = 0;

unsigned char canInit(unsigned int bitrate)
/******************************************************************************
Initialize the hardware to receive CAN messages and start the timer for the
CANopen stack.
INPUT	bitrate		bitrate in kilobit
OUTPUT	1 if successful	
 ******************************************************************************/
{
	unsigned int config;
	unsigned int irq;
	unsigned long int stb_address;
	unsigned int pad_address;
	unsigned int count;
	// 0 normal, 1 disable, 2 loopback, 3 listen-only, 4 configuration, 7 listen all messages
	uint8_t desired_mode = 0; //(parameters[0] & 0x001C) >> 2;
	//    rxbuffer_start = rxbuffer_stop = 0;
	if (bitrate != 1000) {
		//fail
		return 0;
	}
	C1CTRL1bits.WIN = 0;

	//CONFIG CAN
	// Make sure the ECAN module is in configuration mode.
	// It should be this way after a hardware reset, but
	// we make sure anyways.
	C1CTRL1bits.REQOP = 4;
	while (C1CTRL1bits.OPMODE != 4);



	//1Mbaud
	// Setup our frequencies for time quanta calculations.
	// FCAN is selected to be FCY*2 = FP*2 = 140Mhz
	C1CTRL1bits.CANCKS = 1; // 1 => FP*2; 0 => FP
	C1CFG1bits.BRP = 6; //6 = (140MHz/(2*(10*1Mbaud)))-1 [10 TQ/bit = Bit Time]
	// Based on Bit Time
	// 10 = 1(SJW) + 4(Propagation Seg.) + 3(Phase Seg. 1) + 2(Phase Seg. 2)
	// (Progagation Seg. + Phase Seg. 1) >= Phase Seg. 2
	// Phase Seg. 2 > SJW

	C1CFG1bits.SJW = 0; // (Value-1)
	C1CFG2bits.PRSEG = 3; // Set propagation segment time (Value-1)
	C1CFG2bits.SEG1PH = 2; // Set segment 1 time (Value-1)
	C1CFG2bits.SEG2PHTS = 0x1; // Keep segment 2 time programmable
	C1CFG2bits.SEG2PH = 1; // Set phase segment 2 time (Value-1)
	C1CFG2bits.SAM = 1; // Triple-sample for majority rules at bit sample point
	C1FCTRLbits.DMABS = 0x00;

	// Clear all interrupt bits
	C1RXFUL1 = C1RXFUL2 = C1RXOVF1 = C1RXOVF2 = 0x0000;

	// Configure buffer settings.
	C1TR01CON = 0;
	//buffer 0 is transmit
	C1TR01CONbits.TXEN0 = 1;
	C1TR01CONbits.TXEN1 = 1;
	C1TR23CONbits.TXEN2 = 1;
	C1TR23CONbits.TXEN3 = 1;
	C1TR45CONbits.TXEN4 = 1;
	C1TR45CONbits.TXEN5 = 1;
	C1TR67CONbits.TXEN6 = 1;
	C1TR67CONbits.TXEN7 = 0;


	//CONFIG DMA
	//TX
	DMA1CONbits.SIZE = 0; //word transfer mode
	DMA1CONbits.DIR = 0x1; //RAM to peripheral
	DMA1CONbits.AMODE = 0x2; //peripheral indirect addressing mode
	DMA1CONbits.MODE = 0x0; //continuous, no ping-pong
	DMA1REQ = 70; // CAN1 TX
	DMA1CNT = 7; // 8 words per transfer
	DMA1PAD = (volatile unsigned int) &C1TXD;
	DMA1STAL = (unsigned int) ecan1TXMsgBuf;
	DMA1STAH = 0x0;

	//RX
	DMA0CONbits.SIZE = 0;
	DMA0CONbits.DIR = 0; //Read to RAM from peripheral
	DMA0CONbits.AMODE = 2; // Continuous mode, single buffer
	DMA0CONbits.MODE = 0; // Peripheral Indirect Addressing
	DMA0REQ = 34; // CAN1 RX
	DMA0CNT = 7; // 8 words per transfer
	DMA0PAD = (volatile unsigned int) &C1RXD;
	DMA0STAL = (unsigned int) ecan1RXMsgBuf;
	DMA0STAH = 0x0;


	// Enable DMA
	IFS0bits.DMA0IF = 0;
	IFS0bits.DMA1IF = 0;
	DMA0CONbits.CHEN = 1;
	DMA1CONbits.CHEN = 1;
	IEC0bits.DMA0IE = 0; // Disable DMA Channel 0 interrupt (everything is handled in the CAN interrupt)
	IEC0bits.DMA1IE = 0;

	//	C1CTRL1bits.WIN = 1;
	//	C1FMSKSEL1bits.F0MSK = 0x0; //Filter 0 will use mask 0
	//	C1RXM0SIDbits.SID = 0x0; //0x000; // accept all
	//	//C1FEN1bits.FLTEN0 = 1;
	//	C1RXF0SIDbits.SID = 0x0; //0x7EE;// set filter
	//	C1RXM0SIDbits.MIDE = 0x1; //only receive standard frames
	//	C1RXF0SIDbits.EXIDE = 0x0;
	//	C1BUFPNT1bits.F0BP = 0x0; //0x1; //use message buffer 0 to receive data
	//	C1FEN1bits.FLTEN0 = 0x1; //Filter 0 enabled for Identifier match with incoming message
	//	C1CTRL1bits.WIN = 0;

	Ecan1WriteRxAcptFilter(7, 0x000, 0, 7, 0);
	Ecan1WriteRxAcptMask(0, 0x000, 0, 0);

	// Place ECAN1 into normal mode
	desired_mode = 0b000;
	C1CTRL1bits.REQOP = desired_mode;
	while (C1CTRL1bits.OPMODE != desired_mode);

	// Enable interrupts for ECAN1
	ConfigIntCAN1(CAN_INVALID_MESSAGE_INT_DIS & CAN_WAKEUP_INT_DIS & CAN_ERR_INT_DIS &
		CAN_FIFO_INT_DIS & CAN_RXBUF_OVERFLOW_INT_EN &
		CAN_RXBUF_INT_EN & CAN_TXBUF_INT_DIS, CAN_INT_ENABLE & CAN_INT_PRI_5);

	if (CB_Init(&can_rx_circ_buff, can_rx_buffer_array, CAN_RX_BUFF_SIZE) != SUCCESS) {
		return 0;
	}

	return 1;
}

unsigned char canSend(CAN_PORT notused, Message *m)
/******************************************************************************
The driver send a CAN message passed from the CANopen stack
INPUT	CAN_PORT is not used (only 1 avaiable)
	Message *m pointer to message to send
OUTPUT	1 if  hardware -> CAN frame
 ******************************************************************************/
{
	uint32_t word0 = 0, word1 = 0, word2 = 0;
	uint32_t sid10_0 = 0, eid5_0 = 0, eid17_6 = 0;

	// Variables for setting correct TXREQ bit
	static uint8_t bufferSwitch = 0;
	static char firstTime = 1;

	// Divide the identifier into bit-chunks for storage
	// into the registers.
	//    if (message->frame_type == CAN_FRAME_EXT) {
	//        eid5_0 = (message->id & 0x3F);
	//        eid17_6 = (message->id >> 6) & 0xFFF;
	//        sid10_0 = (message->id >> 18) & 0x7FF;
	//        word0 = 1;
	//        word1 = eid17_6;
	//    } else {
	sid10_0 = (m->cob_id & 0x7FF);
	//    }

	word0 |= (sid10_0 << 2);
	word2 |= (eid5_0 << 10);

	// Set remote transmit bits
	if (m->rtr) {
		word0 |= 0x2;
		word2 |= 0x0200;
	}

	//TODO: use multiple transmit buffers
	//    while(C1TR01CONbits.TXREQ1 == 1);
	//
	//    ecan1TXMsgBuf[1][0] = word0;
	//    ecan1TXMsgBuf[1][1] = word1;
	//    ecan1TXMsgBuf[1][2] = ((word2 & 0xFFF0) + m->len);
	//    ecan1TXMsgBuf[1][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//    ecan1TXMsgBuf[1][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//    ecan1TXMsgBuf[1][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//     ecan1TXMsgBuf[1][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//
	//    // Set the correct transfer intialization bit (TXREQ) based on message buffer.
	//    //offset = message->buffer >> 1;
	//    //bufferCtrlRegAddr = (uint16_t *) (&C1TR01CON + offset);
	//    //bit_to_set = 1 << (3 | ((message->buffer & 1) << 3));
	//    //*bufferCtrlRegAddr |= bit_to_set;
	//    C1TR01CONbits.TXEN1 = 1;
	//    C1TR01CONbits.TX0PRI = 0;
	//    C1TR01CONbits.TXREQ1 = 1;
	switch (bufferSwitch) {
	case 0:
		ecan1TXMsgBuf[0][0] = word0;
		ecan1TXMsgBuf[0][1] = word1;
		ecan1TXMsgBuf[0][2] = ((word2 & 0xFFF0) + m->len);
		ecan1TXMsgBuf[0][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
		ecan1TXMsgBuf[0][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
		ecan1TXMsgBuf[0][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
		ecan1TXMsgBuf[0][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
		txreq_bitarray = txreq_bitarray | 0b00000001;

		//	    C1TR01CONbits.TXEN0 = 1;
		//	    C1TR01CONbits.TX0PRI = 0x11;
		//	    C1TR01CONbits.TXREQ0 = 1;
		bufferSwitch++;
		break;
	case 1:
		ecan1TXMsgBuf[1][0] = word0;
		ecan1TXMsgBuf[1][1] = word1;
		ecan1TXMsgBuf[1][2] = ((word2 & 0xFFF0) + m->len);
		ecan1TXMsgBuf[1][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
		ecan1TXMsgBuf[1][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
		ecan1TXMsgBuf[1][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
		ecan1TXMsgBuf[1][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
		txreq_bitarray = txreq_bitarray | 0b00000010;

		//	    C1TR01CONbits.TXEN1 = 1;
		//	    C1TR01CONbits.TXREQ1 = 1;
		bufferSwitch++;
		break;
	case 2:
		ecan1TXMsgBuf[2][0] = word0;
		ecan1TXMsgBuf[2][1] = word1;
		ecan1TXMsgBuf[2][2] = ((word2 & 0xFFF0) + m->len);
		ecan1TXMsgBuf[2][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
		ecan1TXMsgBuf[2][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
		ecan1TXMsgBuf[2][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
		ecan1TXMsgBuf[2][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
		txreq_bitarray = txreq_bitarray | 0b00000100;

		//	    C1TR23CONbits.TXEN2 = 1;
		//	    C1TR23CONbits.TX2PRI = 0x11;
		//	    C1TR23CONbits.TXREQ2 = 1;
		bufferSwitch++;
		break;

	case 3:
		ecan1TXMsgBuf[3][0] = word0;
		ecan1TXMsgBuf[3][1] = word1;
		ecan1TXMsgBuf[3][2] = ((word2 & 0xFFF0) + m->len);
		ecan1TXMsgBuf[3][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
		ecan1TXMsgBuf[3][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
		ecan1TXMsgBuf[3][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
		ecan1TXMsgBuf[3][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
		txreq_bitarray = txreq_bitarray | 0b00001000;

		//	    C1TR23CONbits.TXEN3 = 1;
		//	    C1TR23CONbits.TXREQ3 = 1;
		bufferSwitch++;
		break;
	case 4:
		ecan1TXMsgBuf[4][0] = word0;
		ecan1TXMsgBuf[4][1] = word1;
		ecan1TXMsgBuf[4][2] = ((word2 & 0xFFF0) + m->len);
		ecan1TXMsgBuf[4][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
		ecan1TXMsgBuf[4][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
		ecan1TXMsgBuf[4][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
		ecan1TXMsgBuf[4][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
		txreq_bitarray = txreq_bitarray | 0b00010000;
		//
		//	    C1TR45CONbits.TXEN4 = 1;
		//	    C1TR45CONbits.TX4PRI = 0x11;
		//	    C1TR45CONbits.TXREQ4 = 1;
		bufferSwitch++;
		break;
	case 5:
		ecan1TXMsgBuf[5][0] = word0;
		ecan1TXMsgBuf[5][1] = word1;
		ecan1TXMsgBuf[5][2] = ((word2 & 0xFFF0) + m->len);
		ecan1TXMsgBuf[5][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
		ecan1TXMsgBuf[5][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
		ecan1TXMsgBuf[5][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
		ecan1TXMsgBuf[5][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
		txreq_bitarray = txreq_bitarray | 0b00100000;

		//	    C1TR45CONbits.TXEN5 = 1;
		//	    C1TR45CONbits.TXREQ5 = 1;
		bufferSwitch++;
		break;
	case 6:
		ecan1TXMsgBuf[6][0] = word0;
		ecan1TXMsgBuf[6][1] = word1;
		ecan1TXMsgBuf[6][2] = ((word2 & 0xFFF0) + m->len);
		ecan1TXMsgBuf[6][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
		ecan1TXMsgBuf[6][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
		ecan1TXMsgBuf[6][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
		ecan1TXMsgBuf[6][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
		txreq_bitarray = txreq_bitarray | 0b01000000;

		//	    C1TR67CONbits.TXEN6 = 1;
		//	    C1TR67CONbits.TX6PRI = 0x11;
		//	    C1TR67CONbits.TXREQ6 = 1;
		bufferSwitch=0;
		break;
//	case 7:
//		ecan1TXMsgBuf[7][0] = word0;
//		ecan1TXMsgBuf[7][1] = word1;
//		ecan1TXMsgBuf[7][2] = ((word2 & 0xFFF0) + m->len);
//		ecan1TXMsgBuf[7][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
//		ecan1TXMsgBuf[7][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
//		ecan1TXMsgBuf[7][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
//		ecan1TXMsgBuf[7][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
//		txreq_bitarray = txreq_bitarray | 0b10000000;
//
//		//	    C1TR67CONbits.TXEN7 = 1;
//		//	    C1TR67CONbits.TXREQ7 = 1;
//		bufferSwitch = 0;
//		break;
	default:
		bufferSwitch = 0;
		break;
	}


}

unsigned canReceive(Message* m)
/******************************************************************************
The driver pass a received CAN message to the stack
INPUT	Message *m pointer to received CAN message
OUTPUT	1 if a message received
 ******************************************************************************/
{

	//get the first message in the queue (if any)
	if (CB_ReadMany(&can_rx_circ_buff, m, sizeof(Message)) == SUCCESS) {
		return 1;
	} else {
		return 0;
	}
	//    if(rxbuffer_start!=rxbuffer_stop){
	//        res = &rxbuffer[rxbuffer_start++];
	//        if(rxbuffer_start>CAN_RX_BUF_SIZE){
	//            rxbuffer_start = 0;
	//        }
	//    }
	//    return res;

}

/***************************************************************************/
unsigned char canChangeBaudRate_driver(CAN_HANDLE fd, char* baud)
{
	return 0; //not supported
}

void __attribute__((interrupt, no_auto_psv)) _C1Interrupt(void)
{
	// while(1);
	// Give us a CAN message struct to populate and use
	Message m;
	uint8_t ide = 0;
	uint8_t srr = 0;
	uint32_t id = 0;
	uint8_t index_byte;
	uint16_t buffer;
	uint16_t *ecan_msg_buf_ptr;
	static uint8_t packet_idx;
	unsigned i;

	if (C1INTFbits.TBIF) {
		C1INTFbits.TBIF = 0; //message was transmitted, nothing to do, I guess
	}
	// If the interrupt was fired because of a received message
	// package it all up and store in the queue.
	if (C1INTFbits.RBIF) {
		//LATDbits.LATD8 = !LATDbits.LATD8;
		//find current message in buffer, we overwrite old messages in case the buffer overflows
		//(thus we can handle emergencies etc.)
		//        m = &rxbuffer[rxbuffer_stop++];
		//        if(rxbuffer_stop>CAN_RX_BUF_SIZE){
		//            rxbuffer_stop = 0;
		//        }
		m.cob_id = 0xFFFF;
		m.rtr = 1;
		m.len = 255;

		// Obtain the buffer the message was stored into, checking that the value is valid to refer to a buffer
		//		if (C1VECbits.ICODE < 8) {
		buffer = C1VECbits.ICODE;
		//		}

		ecan_msg_buf_ptr = ecan1RXMsgBuf[buffer];

		// Clear the buffer full status bit so more messages can be received.
		if (C1RXFUL1 & (1 << buffer)) {
			C1RXFUL1 &= ~(1 << buffer);
		}

		//  Move the message from the DMA buffer to a data structure and then push it into our circular buffer.

		// Read the first word to see the message type
		ide = ecan_msg_buf_ptr[0] & 0x0001;
		srr = ecan_msg_buf_ptr[0] & 0x0002;

		/* Format the message properly according to whether it
		 * uses an extended identifier or not.
		 */
		if (ide == 0) {
			m.cob_id = (uint32_t) ((ecan_msg_buf_ptr[0] & 0x1FFC) >> 2);
		} else {
			//ehm, error. only std messages supported for now
		}

		/* If message is a remote transmit request, mark it as such.
		 * Otherwise it will be a regular transmission so fill its
		 * payload with the relevant data.
		 */
		if (srr == 1) {
			m.rtr = 1; //TODO: do we need to copy the payload??? I don't think so?
		} else {
			m.rtr = 0;

			m.len = (uint8_t) (ecan_msg_buf_ptr[2] & 0x000F);
			m.data[0] = (uint8_t) (ecan_msg_buf_ptr[3]&0xFF);
			m.data[1] = (uint8_t) ((ecan_msg_buf_ptr[3] & 0xFF00) >> 8);
			//LED3 != LED3;//message.payload[1];
			//LED2 =  message.payload[0];
			m.data[2] = (uint8_t) (ecan_msg_buf_ptr[4]&0xFF);
			m.data[3] = (uint8_t) ((ecan_msg_buf_ptr[4] & 0xFF00) >> 8);
			m.data[4] = (uint8_t) (ecan_msg_buf_ptr[5]&0xFF);
			m.data[5] = (uint8_t) ((ecan_msg_buf_ptr[5] & 0xFF00) >> 8);
			m.data[6] = (uint8_t) (ecan_msg_buf_ptr[6]&0xFF);
			m.data[7] = (uint8_t) ((ecan_msg_buf_ptr[6] & 0xFF00) >> 8);


		}

		//copy message to circular buffer
		CB_WriteMany(&can_rx_circ_buff, &m, sizeof(Message), 1);

		// Be sure to clear the interrupt flag.
		C1RXFUL1 = 0;
		C1INTFbits.RBIF = 0;
	}

	// Clear the general ECAN1 interrupt flag.
	IFS0bits.DMA0IF = 0;
	IFS0bits.DMA1IF = 0;
	CAN1ClearRXFUL1();
	CAN1ClearRXFUL2();
	CAN1ClearRXOVF1();
	CAN1ClearRXOVF2();
	IFS2bits.C1IF = 0;
}