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
#include "motor_objdict.h"

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

void reset_board()
{
    asm ("RESET");
    while(1);
}


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
//	Ecan1Init();
	canInit(1000);
//	DMA0Init();
//	DMA2Init();

	Motor_Board_Data.NMT_Slave_Node_Reset_Callback = reset_board;

	setNodeId(&Motor_Board_Data, 0x01);
	setState(&Motor_Board_Data, Initialisation);	// Init the state

	LED1 = 1;

	/* Enable ECAN1 Interrupt */
	IEC2bits.C1IE = 1;
	C1INTEbits.TBIE = 1;
	C1INTEbits.RBIE = 1;

//	Message m;
//
//	m.cob_id = 0x1234;
//	m.data[0] = 4;
//	m.data[1] = 4;
//	m.data[2] = 4;
//	m.data[3] = 4;
//	m.data[4] = 4;
//	m.data[5] = 4;
//	m.data[6] = 4;
//	m.data[7] = 4;
//	m.len = 8;
//	m.rtr = 0;

	/* Write a Message in ECAN1 Transmit Buffer
       Request Message Transmission            */
//	canSend(&Motor_Board_Data, &m);
//
	/* Loop infinitely */
	while (1) {
		Nop();
	}
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
//void __attribute__((interrupt, no_auto_psv)) _C1Interrupt(void)
//{
//	IFS2bits.C1IF = 0; // clear interrupt flag
//	if (C1INTFbits.TBIF) {
//		C1INTFbits.TBIF = 0;
//	}
//
//	if (C1INTFbits.RBIF) {
//		// read the message
//		if (C1RXFUL1bits.RXFUL1 == 1) {
//			rx_ecan1message.buffer = 1;
//			C1RXFUL1bits.RXFUL1 = 0;
//		}
//
//		RxECAN1(&rx_ecan1message);
//		C1INTFbits.RBIF = 0;
//	}
//	LED4 = 1;
//}

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