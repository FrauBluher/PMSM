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
#include "../src/superball_circularbuffer.h"
#include <ecan.h>
#include <p33Exxxx.h>
#include "../src/common.h"
#include <pps.h>

///////////////////////////////////////////////////////////////////////////////
////////////////////// USER FUNCTIONS Replace when this is a library //////////

///////////////////////////////////////////////////////////////////////////////
////////////////////// USER FUNCTIONS Replace when this is a library //////////

//internal RX buffer for CAN messages


static unsigned int ecan1RXMsgBuf[4][8] __attribute__((aligned(4 * 16)));
static unsigned int ecan1TXMsgBuf[4][8] __attribute__((aligned(4 * 16)));
//#define CAN_RX_BUF_SIZE 1
//static volatile Message rxbuffer[CAN_RX_BUF_SIZE]; //this is an internal buffer for received messages
//static volatile uint8_t rxbuffer_start;
//static volatile uint8_t rxbuffer_stop;
#define CAN_RX_BUFF_SIZE 5*sizeof(Message)
uint8_t can_rx_buffer_array[CAN_RX_BUFF_SIZE];
CircularBuffer can_rx_circ_buff;
static uint8_t txreq_bitarray = 0;


// Define ECAN Message Buffers
extern __eds__ ECAN1MSGBUF ecan1msgBuf __attribute__((space(eds), aligned(ECAN1_MSG_BUF_LENGTH * 16)));

// CAN Messages in RAM
extern mID rx_ecan1message;

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
	C1CTRL1bits.WIN = 0; // Allow configuration of masks and filters

	//CONFIG CAN
	// Make sure the ECAN module is in configuration mode.
	// It should be this way after a hardware reset, but
	// we make sure anyways.
	C1CTRL1bits.REQOP = 4;
	while (C1CTRL1bits.OPMODE != 4);



	//1Mbaud
	// Setup our frequencies for time quanta calculations.
	// FCAN is selected to be FCY*2 = FP*2 = 140Mhz
	C1CTRL1bits.CANCKS = 0; // 1 => FP*2; 0 => FP
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
	C1FCTRLbits.DMABS = 0b000; /* 4 CAN Message Buffers in DMA RAM */

	//	/* Enter Normal Mode */
	//	C1CTRL1bits.REQOP = 0;
	//	while (C1CTRL1bits.OPMODE != 0);

	// Clear all interrupt bits
	C1RXFUL1 = C1RXFUL2 = C1RXOVF1 = C1RXOVF2 = 0x0000;
	C1TR01CONbits.TXEN0 = 1; /* ECAN1, Buffer 0 is a Transmit Buffer */
	C1TR01CONbits.TXEN1 = 0; /* ECAN1, Buffer 1 is a Receive Buffer */
	C1TR01CONbits.TX0PRI = 0b11; /* Message Buffer 0 Priority Level */
	C1TR01CONbits.TX1PRI = 0b11; /* Message Buffer 1 Priority Level */

	// Place ECAN1 into normal mode
	desired_mode = 0b000;
	C1CTRL1bits.REQOP = desired_mode;
	while (C1CTRL1bits.OPMODE != desired_mode);


	//	CONFIG DMA





	//	 Enable DMA
	IFS0bits.DMA0IF = 0;
	IFS0bits.DMA1IF = 0;
	DMA0CONbits.CHEN = 1;
	DMA1CONbits.CHEN = 1;
	IEC0bits.DMA0IE = 0; // Disable DMA Channel 0 interrupt (everything is handled in the CAN interrupt)
	IEC0bits.DMA1IE = 0;

	if (CB_Init(&can_rx_circ_buff, can_rx_buffer_array, CAN_RX_BUFF_SIZE) != SUCCESS) {
		return 0;
	}

	//Unlock PPS Registers
	__builtin_write_OSCCONL(OSCCON & ~(1 << 6));

	TRISFbits.TRISF4 = 1;
	TRISFbits.TRISF5 = 0;

	IN_FN_PPS_C1RX = IN_PIN_PPS_RP100;
	OUT_PIN_PPS_RP101 = OUT_FN_PPS_C1TX;

	//Lock PPS Registers
	__builtin_write_OSCCONL(OSCCON | (1 << 6));

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
	while (C1TR01CONbits.TXREQ1 == 1);

	ecan1TXMsgBuf[0][0] = word0;
	ecan1TXMsgBuf[0][1] = word1;
	ecan1TXMsgBuf[0][2] = ((word2 & 0xFFF0) + m->len);
	ecan1TXMsgBuf[0][3] = (((uint16_t) m->data[1]) << 8) | (m->data[0]&0xFF);
	ecan1TXMsgBuf[0][4] = (((uint16_t) m->data[3]) << 8) | (m->data[2]&0xFF);
	ecan1TXMsgBuf[0][5] = (((uint16_t) m->data[5]) << 8) | (m->data[4]&0xFF);
	ecan1TXMsgBuf[0][6] = (((uint16_t) m->data[7]) << 8) | (m->data[6]&0xFF);
	C1TR01CONbits.TXREQ0 = 1;


	// Set the correct transfer intialization bit (TXREQ) based on message buffer.
	//offset = message->buffer >> 1;
	//bufferCtrlRegAddr = (uint16_t *) (&C1TR01CON + offset);
	//bit_to_set = 1 << (3 | ((message->buffer & 1) << 3));
	//*bufferCtrlRegAddr |= bit_to_set;

	//    switch(bufferSwitch){
	//    case 0:
	////	    if(txreq_bitarray&00000001){
	////
	////	    }
	//	    ecan1TXMsgBuf[0][0] = word0;
	//	    ecan1TXMsgBuf[0][1] = word1;
	//	    ecan1TXMsgBuf[0][2] = ((word2 & 0xFFF0) + m->len);
	//	    ecan1TXMsgBuf[0][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//	    ecan1TXMsgBuf[0][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//	    ecan1TXMsgBuf[0][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//	    ecan1TXMsgBuf[0][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//	    txreq_bitarray = txreq_bitarray|00000001;
	//
	////	    C1TR01CONbits.TXEN0 = 1;
	////	    C1TR01CONbits.TX0PRI = 0x11;
	////	    C1TR01CONbits.TXREQ0 = 1;
	//	    bufferSwitch=0;
	//	    break;
	//    case 1:
	//	    ecan1TXMsgBuf[1][0] = word0;
	//	    ecan1TXMsgBuf[1][1] = word1;
	//	    ecan1TXMsgBuf[1][2] = ((word2 & 0xFFF0) + m->len);
	//	    ecan1TXMsgBuf[1][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//	    ecan1TXMsgBuf[1][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//	    ecan1TXMsgBuf[1][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//	    ecan1TXMsgBuf[1][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//	    txreq_bitarray = txreq_bitarray|00000010;
	//
	////	    C1TR01CONbits.TXEN1 = 1;
	////	    C1TR01CONbits.TXREQ1 = 1;
	//	    bufferSwitch++;
	//	    break;
	//    case 2:
	//	    ecan1TXMsgBuf[2][0] = word0;
	//	    ecan1TXMsgBuf[2][1] = word1;
	//	    ecan1TXMsgBuf[2][2] = ((word2 & 0xFFF0) + m->len);
	//	    ecan1TXMsgBuf[2][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//	    ecan1TXMsgBuf[2][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//	    ecan1TXMsgBuf[2][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//	    ecan1TXMsgBuf[2][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//	    txreq_bitarray = txreq_bitarray|00000100;
	//
	////	    C1TR23CONbits.TXEN2 = 1;
	////	    C1TR23CONbits.TX2PRI = 0x11;
	////	    C1TR23CONbits.TXREQ2 = 1;
	//	    bufferSwitch++;
	//	    break;
	//
	//    case 3:
	//	    ecan1TXMsgBuf[3][0] = word0;
	//	    ecan1TXMsgBuf[3][1] = word1;
	//	    ecan1TXMsgBuf[3][2] = ((word2 & 0xFFF0) + m->len);
	//	    ecan1TXMsgBuf[3][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//	    ecan1TXMsgBuf[3][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//	    ecan1TXMsgBuf[3][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//	    ecan1TXMsgBuf[3][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//	    txreq_bitarray = txreq_bitarray|00001000;
	//
	////	    C1TR23CONbits.TXEN3 = 1;
	////	    C1TR23CONbits.TXREQ3 = 1;
	//	    bufferSwitch++;
	//	    break;
	//    case 4:
	//	    ecan1TXMsgBuf[4][0] = word0;
	//	    ecan1TXMsgBuf[4][1] = word1;
	//	    ecan1TXMsgBuf[4][2] = ((word2 & 0xFFF0) + m->len);
	//	    ecan1TXMsgBuf[4][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//	    ecan1TXMsgBuf[4][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//	    ecan1TXMsgBuf[4][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//	    ecan1TXMsgBuf[4][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//	    txreq_bitarray = txreq_bitarray|00010000;
	//
	////	    C1TR45CONbits.TXEN4 = 1;
	////	    C1TR45CONbits.TX4PRI = 0x11;
	////	    C1TR45CONbits.TXREQ4 = 1;
	//	    bufferSwitch++;
	//	    break;
	//    case 5:
	//	    ecan1TXMsgBuf[5][0] = word0;
	//	    ecan1TXMsgBuf[5][1] = word1;
	//	    ecan1TXMsgBuf[5][2] = ((word2 & 0xFFF0) + m->len);
	//	    ecan1TXMsgBuf[5][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//	    ecan1TXMsgBuf[5][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//	    ecan1TXMsgBuf[5][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//	    ecan1TXMsgBuf[5][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//	    txreq_bitarray = txreq_bitarray|00100000;
	//
	////	    C1TR45CONbits.TXEN5 = 1;
	////	    C1TR45CONbits.TXREQ5 = 1;
	//	    bufferSwitch++;
	//	    break;
	//    case 6:
	//	    ecan1TXMsgBuf[6][0] = word0;
	//	    ecan1TXMsgBuf[6][1] = word1;
	//	    ecan1TXMsgBuf[6][2] = ((word2 & 0xFFF0) + m->len);
	//	    ecan1TXMsgBuf[6][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//	    ecan1TXMsgBuf[6][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//	    ecan1TXMsgBuf[6][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//	    ecan1TXMsgBuf[6][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//	    txreq_bitarray = txreq_bitarray|01000000;
	//
	////	    C1TR67CONbits.TXEN6 = 1;
	////	    C1TR67CONbits.TX6PRI = 0x11;
	////	    C1TR67CONbits.TXREQ6 = 1;
	//	    bufferSwitch++;
	//	    break;
	//    case 7:
	//	    ecan1TXMsgBuf[7][0] = word0;
	//	    ecan1TXMsgBuf[7][1] = word1;
	//	    ecan1TXMsgBuf[7][2] = ((word2 & 0xFFF0) + m->len);
	//	    ecan1TXMsgBuf[7][3] = (((uint16_t) m->data[1]) << 8) |(m->data[0]&0xFF);
	//	    ecan1TXMsgBuf[7][4] = (((uint16_t) m->data[3]) << 8) |(m->data[2]&0xFF);
	//	    ecan1TXMsgBuf[7][5] = (((uint16_t) m->data[5]) << 8) |(m->data[4]&0xFF);
	//	    ecan1TXMsgBuf[7][6] = (((uint16_t) m->data[7]) << 8) |(m->data[6]&0xFF);
	//	    txreq_bitarray = txreq_bitarray|10000000;
	//
	////	    C1TR67CONbits.TXEN7 = 1;
	////	    C1TR67CONbits.TXREQ7 = 1;
	//	    bufferSwitch=0;
	//	    break;
	//    default:
	//	    bufferSwitch = 0;
	//	    break;
	//    }


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
	IFS2bits.C1IF = 0; // clear interrupt flag
	if (C1INTFbits.TBIF) {
		C1INTFbits.TBIF = 0;
	}

	if (C1INTFbits.RBIF) {
		LED4 = 1;
		// read the message
		if (C1RXFUL1bits.RXFUL1 == 1) {
			rx_ecan1message.buffer = 1;
			C1RXFUL1bits.RXFUL1 = 0;
		}


		//RxECAN1(&rx_ecan1message); // We replace this with our own RX function.
		// in this example RxECAN1 is found in main.c.
		C1INTFbits.RBIF = 0;
	}



	//
	//	// while(1);
	//	// Give us a CAN message struct to populate and use
	//	Message m;
	//	uint8_t ide = 0;
	//	uint8_t srr = 0;
	//	uint32_t id = 0;
	//	uint8_t index_byte;
	//	uint16_t buffer;
	//	uint16_t *ecan_msg_buf_ptr;
	//	static uint8_t packet_idx;
	//	unsigned i;
	//
	//	if (C1INTFbits.TBIF) {
	//		C1INTFbits.TBIF = 0; //message was transmitted, nothing to do, I guess
	//	}
	//	// If the interrupt was fired because of a received message
	//	// package it all up and store in the queue.
	//	if (C1INTFbits.RBIF) {
	//		//LATDbits.LATD8 = !LATDbits.LATD8;
	//		//find current message in buffer, we overwrite old messages in case the buffer overflows
	//		//(thus we can handle emergencies etc.)
	//		//        m = &rxbuffer[rxbuffer_stop++];
	//		//        if(rxbuffer_stop>CAN_RX_BUF_SIZE){
	//		//            rxbuffer_stop = 0;
	//		//        }
	//		m.cob_id = 0xFFFF;
	//		m.rtr = 1;
	//		m.len = 255;
	//
	//		// Obtain the buffer the message was stored into, checking that the value is valid to refer to a buffer
	//		if (C1VECbits.ICODE < 4) {
	//			buffer = C1VECbits.ICODE;
	//		}
	//
	//		ecan_msg_buf_ptr = ecan1RXMsgBuf[buffer];
	//
	//		// Clear the buffer full status bit so more messages can be received.
	//		if (C1RXFUL1 & (1 << buffer)) {
	//			C1RXFUL1 &= ~(1 << buffer);
	//		}
	//
	//		//  Move the message from the DMA buffer to a data structure and then push it into our circular buffer.
	//
	//		// Read the first word to see the message type
	//		ide = ecan_msg_buf_ptr[0] & 0x0001;
	//		srr = ecan_msg_buf_ptr[0] & 0x0002;
	//
	//		/* Format the message properly according to whether it
	//		 * uses an extended identifier or not.
	//		 */
	//		if (ide == 0) {
	//			m.cob_id = (uint32_t) ((ecan_msg_buf_ptr[0] & 0x1FFC) >> 2);
	//		} else {
	//			//ehm, error. only std messages supported for now
	//		}
	//
	//		/* If message is a remote transmit request, mark it as such.
	//		 * Otherwise it will be a regular transmission so fill its
	//		 * payload with the relevant data.
	//		 */
	//		if (srr == 1) {
	//			m.rtr = 1; //TODO: do we need to copy the payload??? I don't think so?
	//		} else {
	//			m.rtr = 0;
	//
	//			m.len = (uint8_t) (ecan_msg_buf_ptr[2] & 0x000F);
	//			m.data[0] = (uint8_t) (ecan_msg_buf_ptr[3]&0xFF);
	//			m.data[1] = (uint8_t) ((ecan_msg_buf_ptr[3] & 0xFF00) >> 8);
	//			//LED3 != LED3;//message.payload[1];
	//			//LED2 =  message.payload[0];
	//			m.data[2] = (uint8_t) (ecan_msg_buf_ptr[4]&0xFF);
	//			m.data[3] = (uint8_t) ((ecan_msg_buf_ptr[4] & 0xFF00) >> 8);
	//			m.data[4] = (uint8_t) (ecan_msg_buf_ptr[5]&0xFF);
	//			m.data[5] = (uint8_t) ((ecan_msg_buf_ptr[5] & 0xFF00) >> 8);
	//			m.data[6] = (uint8_t) (ecan_msg_buf_ptr[6]&0xFF);
	//			m.data[7] = (uint8_t) ((ecan_msg_buf_ptr[6] & 0xFF00) >> 8);
	//
	//
	//		}
	//
	//		//copy message to circular buffer
	//		CB_WriteMany(&can_rx_circ_buff, &m, sizeof(Message), 1);
	//
	//		// Be sure to clear the interrupt flag.
	//		C1RXFUL1 = 0;
	//		C1INTFbits.RBIF = 0;
	//	}
	//
	//	// Clear the general ECAN1 interrupt flag.
	//	IFS0bits.DMA0IF = 0;
	//	IFS0bits.DMA1IF = 0;
	//	CAN1ClearRXFUL1();
	//	CAN1ClearRXFUL2();
	//	CAN1ClearRXOVF1();
	//	CAN1ClearRXOVF2();
	//	IFS2bits.C1IF = 0;
}