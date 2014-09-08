/*******************************************************************************
  ce427 main source file

  Company:
    Microchip Technology Inc.

  File Name:
    main.c

  Summary:
    This file consists of functions that send and receive messages through the
    ECAN1 and ECAN2 when the transmitter and receiver are crosswired.

 *******************************************************************************/
/*******************************************************************************
Copyright (c) 2012 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *******************************************************************************/
// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
#include <xc.h>
#include "ecan1_config.h"
#include "common.h"

#if __XC16_VERSION < 1011
#warning "Please upgrade to XC16 v1.11 or newer."
#endif

// *****************************************************************************
// *****************************************************************************
// Section: Macros for Configuration Fuse Registers:
// *****************************************************************************
// *****************************************************************************
/* Invoke macros to set up  device configuration fuse registers.The fuses will
   select the oscillator source, power-up timers, watch-dog timers etc. The
   macros are defined within the device header files. The configuration fuse
   registers reside in Flash memory.
 */
//DSPIC33EP512MU810 Configuration Bit Settings
//'C' source line config statements
#define TRIS_LED1     TRISBbits.TRISB8
#define TRIS_LED2     TRISBbits.TRISB9
#define TRIS_LED3     TRISBbits.TRISB10
#define TRIS_LED4     TRISBbits.TRISB11

#define LED1     LATBbits.LATB8
#define LED2     LATBbits.LATB9
#define LED3     LATBbits.LATB10
#define LED4     LATBbits.LATB11

_FOSCSEL(FNOSC_FRC & IESO_OFF);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_NONE);
_FWDT(FWDTEN_OFF);
_FICD(ICS_PGD1 & JTAGEN_OFF);

// *****************************************************************************
// *****************************************************************************
// Section: File Scope or Global Constants
// *****************************************************************************
// *****************************************************************************
// Define ECAN Message Buffers
__eds__ ECAN1MSGBUF ecan1msgBuf __attribute__((space(eds), aligned(ECAN1_MSG_BUF_LENGTH * 16)));

// CAN Messages in RAM
mID rx_ecan1message;

// *****************************************************************************
// Section: Static Function declaration
// *****************************************************************************
void OscConfig(void);
void ClearIntrflags(void);
void Ecan1WriteMessage(void);
// *****************************************************************************
// Section: Function definition
// *****************************************************************************

/*


 All LEDs on the motor board should be illuminated if the CAN TX/RX was successful.
 LED1 = INIT COMPLETE
 LED2 = TRANSMISSION SUCCESSFUL
 LED3 = TRANSMISSION RECEIVED
 LED4 = CAN INTERRUPT WORKING CORRECTLY (TX REQUESTS)
 

 */
int main(void)
{
	TRIS_LED1 = 0;
	TRIS_LED2 = 0;
	TRIS_LED3 = 0;
	TRIS_LED4 = 0;

	/* Configure Oscillator Clock Source     */
	OscConfig();

	/* Clear Interrupt Flags                 */
	ClearIntrflags();

	/* ECAN1 Initialisation
       Configure DMA Channel 0 for ECAN1 Transmit
       Configure DMA Channel 2 for ECAN1 Receive */
	Ecan1Init();
	DMA0Init();
	DMA2Init();
	LED1 = 1;

	/* Enable ECAN1 Interrupt */
	IEC2bits.C1IE = 1;
	C1INTEbits.TBIE = 1;
	C1INTEbits.RBIE = 1;

	/* Write a Message in ECAN1 Transmit Buffer
       Request Message Transmission            */
	Ecan1WriteMessage();
	C1TR01CONbits.TXREQ0 = 1;

	/* Loop infinitely */
	while (1) {
		Nop();
	}
}

/******************************************************************************
 * Function:        void Ecan1WriteMessage(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        This function is used to write the ECAN1 buffer with the
 *                  identifiers and the data. Writes the message to be
 *                  transmitted.
 *****************************************************************************/
void Ecan1WriteMessage(void)
{
	/* Writing the message for Transmission
    Ecan1WriteTxMsgBufId(unsigned int buf, long txIdentifier, unsigned int ide, unsigned int remoteTransmit);
    Ecan1WriteTxMsgBufData(unsigned int buf, unsigned int dataLength, unsigned int data1, unsigned int data2, unsigned int data3, unsigned int data4);

    buf -> Transmit Buffer number

    txIdentifier -> SID<10:0> : EID<17:0>

    ide = 0 -> Message will transmit standard identifier
    ide = 1 -> Message will transmit extended identifier

    remoteTransmit = 0 -> Normal message
    remoteTransmit = 1 -> Message will request remote transmission

    dataLength -> Data length can be from 0 to 8 bytes

    data1, data2, data3, data4 -> Data words (2 bytes) each

	 */
	Ecan1WriteTxMsgBufId(0, 0x1FFEFFFF, 1, 0);
	Ecan1WriteTxMsgBufData(0, 8, 0x1111, 0x2222, 0x3333, 0x4444);
}

/******************************************************************************
 * Function:        void RxECAN1(mID *message)
 *
 * PreCondition:    None
 *
 * Input:          *message: a pointer to the message structure in RAM
 *                  that will store the message.
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        Moves the message from the DMA memory to RAM.
 *****************************************************************************/
void RxECAN1(mID *message)
{
	unsigned int ide = 0;
	unsigned int srr = 0;
	unsigned long id = 0;

	/*
	Standard Message Format:
	Word0 : 0bUUUx xxxx xxxx xxxx
		     |____________|||
			 SID10:0   SRR IDE(bit 0)
	Word1 : 0bUUUU xxxx xxxx xxxx
			  |____________|
			    EID17:6
	Word2 : 0bxxxx xxx0 UUU0 xxxx
		  |_____||         |__|
		  EID5:0 RTR         DLC
	word3-word6: data bytes
	word7: filter hit code bits
    
	Substitute Remote Request Bit
	SRR->    "0"     Normal Message
		"1"  Message will request remote transmission
    
	Extended  Identifier Bit
	IDE->     "0"  Message will transmit standard identifier
		   "1"  Message will transmit extended identifier
    
	Remote Transmission Request Bit
	RTR->     "0"  Message transmitted is a normal message
		"1"  Message transmitted is a remote message
	 */
	/* read word 0 to see the message type */
	ide = ecan1msgBuf[message->buffer][0] & 0x0001;
	srr = ecan1msgBuf[message->buffer][0] & 0x0002;

	/* check to see what type of message it is */
	/* message is standard identifier */
	if (ide == 0) {
		message->id = (ecan1msgBuf[message->buffer][0] & 0x1FFC) >> 2;
		message->frame_type = CAN_FRAME_STD;
	}/* mesage is extended identifier */
	else {
		id = ecan1msgBuf[message->buffer][0] & 0x1FFC;
		message->id = id << 16;
		id = ecan1msgBuf[message->buffer][1] & 0x0FFF;
		message->id = message->id + (id << 6);
		id = (ecan1msgBuf[message->buffer][2] & 0xFC00) >> 10;
		message->id = message->id + id;
		message->frame_type = CAN_FRAME_EXT;
	}

	/* check to see what type of message it is */
	/* RTR message */
	if (srr == 1) {
		message->message_type = CAN_MSG_RTR;
	}/* normal message */
	else {
		message->message_type = CAN_MSG_DATA;
		message->data[0] = (unsigned char) ecan1msgBuf[message->buffer][3];
		message->data[1] = (unsigned char) ((ecan1msgBuf[message->buffer][3] & 0xFF00) >> 8);
		message->data[2] = (unsigned char) ecan1msgBuf[message->buffer][4];
		message->data[3] = (unsigned char) ((ecan1msgBuf[message->buffer][4] & 0xFF00) >> 8);
		message->data[4] = (unsigned char) ecan1msgBuf[message->buffer][5];
		message->data[5] = (unsigned char) ((ecan1msgBuf[message->buffer][5] & 0xFF00) >> 8);
		message->data[6] = (unsigned char) ecan1msgBuf[message->buffer][6];
		message->data[7] = (unsigned char) ((ecan1msgBuf[message->buffer][6] & 0xFF00) >> 8);
		message->data_length = (unsigned char) (ecan1msgBuf[message->buffer][2] & 0x000F);
	}
}

/******************************************************************************
 * Function:        void ClearIntrflags(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:         Clears all the interrupt flag registers.
 *****************************************************************************/
void ClearIntrflags(void)
{
	/* Clear Interrupt Flags */
	IFS0 = 0;
	IFS1 = 0;
	IFS2 = 0;
	IFS3 = 0;
	IFS4 = 0;
}

/******************************************************************************
 * Function:        void OscConfig(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:       This function configures the Oscillator to work at 60MHz.
 *****************************************************************************/
void OscConfig(void)
{
	PLLFBD = 74;
	CLKDIVbits.PLLPRE = 0;
	CLKDIVbits.PLLPOST = 0;

	// Initiate Clock Switch to FRC oscillator with PLL (NOSC=0b001)
	__builtin_write_OSCCONH(0x01);

	__builtin_write_OSCCONL(OSCCON | 0x01);

	// Wait for Clock switch to occur
	while (OSCCONbits.COSC != 0b001);

	// Wait for PLL to lock
	while (OSCCONbits.LOCK != 1);
}

/******************************************************************************
 * Function:      void __attribute__((interrupt, no_auto_psv))_C1Interrupt(void)
 *
 * PreCondition:  None
 *
 * Input:         None
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      Interrupt service routine to handle CAN1 Transmit and
 *                recieve interrupt.
 *****************************************************************************/
void __attribute__((interrupt, no_auto_psv)) _C1Interrupt(void)
{
	IFS2bits.C1IF = 0; // clear interrupt flag
	if (C1INTFbits.TBIF) {
		C1INTFbits.TBIF = 0;
	}

	if (C1INTFbits.RBIF) {
		// read the message
		if (C1RXFUL1bits.RXFUL1 == 1) {
			rx_ecan1message.buffer = 1;
			C1RXFUL1bits.RXFUL1 = 0;
		}

		RxECAN1(&rx_ecan1message);
		C1INTFbits.RBIF = 0;
	}
	LED4 = 1;
}

//------------------------------------------------------------------------------
//    DMA interrupt handlers
//------------------------------------------------------------------------------

/******************************************************************************
 * Function:   void __attribute__((interrupt, no_auto_psv)) _DMA0Interrupt(void)
 *
 * PreCondition:  None
 *
 * Input:         None
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      Interrupt service routine to handle DMA0interrupt
 *****************************************************************************/
void __attribute__((interrupt, no_auto_psv)) _DMA0Interrupt(void)
{
	IFS0bits.DMA0IF = 0; // Clear the DMA0 Interrupt Flag;
	LED2 = 1;
}

/******************************************************************************
 * Function:   void __attribute__((interrupt, no_auto_psv)) _DMA2Interrupt(void)
 *
 * PreCondition:  None
 *
 * Input:         None
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      Interrupt service routine to handle DMA2interrupt
 *****************************************************************************/
void __attribute__((interrupt, no_auto_psv)) _DMA2Interrupt(void)
{
	IFS1bits.DMA2IF = 0; // Clear the DMA2 Interrupt Flag;
	LED3 = 1;
}