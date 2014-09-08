/*******************************************************************************
  ECAN1 Configuration source file

  Company:
    Microchip Technology Inc.

  File Name:
    ecan1_config.c

  Summary:
    Initializes and configures the ECAN1 and DMA modules.
    
  Description:
    This source file initializes the DMA and configures two DMA channels one
    each for transmission and reception. The ECAN is also initialized, its clock
    configured to be the system clock itself and the filters are also configured
    to accept a particular message.
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
#include <pps.h>
#include <dma.h>

/******************************************************************************
 * Function:      void DMA0Init(void)
 *
 * PreCondition:  None
 *
 * Input:         None
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      DMA0 initialization/configuration function.
 *                Direction: Read from RAM and write to the C1TXD register
 *                AMODE: Register indirect with post increment
 *                MODE: Continuous, Ping-Pong Mode
 *                IRQ: ECAN1 Transmit Interrupt
 *****************************************************************************/
void DMA0Init( void )
{
    //     DMACS0=0;
    DMAPWC = 0;
    DMARQC = 0;
    DMA0CON = 0x2020;
    DMA0PAD = ( int ) &C1TXD;   /* ECAN 1 (C1TXD) */
    DMA0CNT = 0x0007;
    DMA0REQ = 0x0046;           /* ECAN 1 Transmit */

    #ifdef _HAS_DMA_
    DMA0STAL = __builtin_dmaoffset( ecan1msgBuf );
    DMA0STAH = __builtin_dmapage( ecan1msgBuf );
    #else
    DMA0STAL = ( uint16_t ) ( int_least24_t ) ( &ecan1msgBuf );
    DMA0STAH = ( uint16_t ) ( int_least24_t ) ( &ecan1msgBuf );
    #endif
    EnableIntDMA0;
    DMA0CONbits.CHEN = 1;
}

/******************************************************************************
 * Function:      void DMA2Init(void)
 *
 * PreCondition:  None
 *
 * Input:         None
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      DMA0 initialization/configuration function.
 *                Direction: Read from RAM and write to the C1RXD register
 *                AMODE: Register indirect with post increment
 *                MODE: Continuous, Ping-Pong Mode
 *                IRQ: ECAN1 Transmit Interrupt
 *****************************************************************************/
void DMA2Init( void )
{
    //     DMACS0=0;
    DMAPWC = 0;
    DMARQC = 0;
    DMA2CON = 0x0020;
    DMA2PAD = ( int ) &C1RXD;   /* ECAN 1 (C1RXD) */
    DMA2CNT = 0x0007;
    DMA2REQ = 0x0022;           /* ECAN 1 Receive */

    #ifdef _HAS_DMA_
    DMA2STAL = __builtin_dmaoffset( ecan1msgBuf );
    DMA2STAH = __builtin_dmapage( ecan1msgBuf );
    #else
    DMA2STAL = ( uint16_t ) ( int_least24_t ) ( &ecan1msgBuf );
    DMA2STAH = ( uint16_t ) ( int_least24_t ) ( &ecan1msgBuf );
    #endif
    EnableIntDMA2;
    DMA2CONbits.CHEN = 1;
}

/******************************************************************************
 * Function:      void Ecan1ClkInit(void)
 *
 * PreCondition:  None
 *
 * Input:         None
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      ECAN1 clock initialization function
 *                This function is used to configure the clock used for the
 *                ECAN1 module during transmission/reception.
 *****************************************************************************/
void Ecan1ClkInit( void )
{
    /* FCAN is selected to be FCY
   FCAN = FCY = 40MHz */
    //    C1CTRL1bits.CANCKS = 0x1;
    /*
Bit Time = (Sync Segment + Propagation Delay + Phase Segment 1 + Phase Segment 2)=20*TQ
Phase Segment 1 = 8TQ
Phase Segment 2 = 6Tq
Propagation Delay = 5Tq
Sync Segment = 1TQ
CiCFG1<BRP> =(FCAN /(2 ×N×FBAUD))– 1
*/
    /* Synchronization Jump Width set to 4 TQ */
    C1CFG1bits.SJW = 0x3;

    /* Baud Rate Prescaler */
    C1CFG1bits.BRP = BRP_VAL;

    /* Phase Segment 1 time is 8 TQ */
    C1CFG2bits.SEG1PH = 0x7;

    /* Phase Segment 2 time is set to be programmable */
    C1CFG2bits.SEG2PHTS = 0x1;

    /* Phase Segment 2 time is 6 TQ */
    C1CFG2bits.SEG2PH = 0x5;

    /* Propagation Segment time is 5 TQ */
    C1CFG2bits.PRSEG = 0x4;

    /* Bus line is sampled three times at the sample point */
    C1CFG2bits.SAM = 0x1;
}

/******************************************************************************
 * Function:     void Ecan1Init(void)
 *
 * PreCondition:  None
 *
 * Input:         None
 *
 * Output:        None
 *
 * Side Effects:  None
 *
 * Overview:      ECAN1 initialization function.This function is used to
 *                initialize the ECAN1 module by configuring the message
 *                buffers, and the acceptance filters and
 *                setting appropriate masks for the same.
 *****************************************************************************/
void Ecan1Init( void )
{
    /* Request Configuration Mode */
    C1CTRL1bits.REQOP = 4;
    while( C1CTRL1bits.OPMODE != 4 );

    Ecan1ClkInit();

    C1FCTRLbits.DMABS = 0b000;     /* 4 CAN Message Buffers in DMA RAM */

    /*    Filter Configuration

    Ecan1WriteRxAcptFilter(int n, long identifier, unsigned int exide,unsigned int bufPnt,unsigned int maskSel)

    n = 0 to 15 -> Filter number

    identifier -> SID <10:0> : EID <17:0> 

    exide = 0 -> Match messages with standard identifier addresses 
    exide = 1 -> Match messages with extended identifier addresses 

    bufPnt = 0 to 14  -> RX Buffer 0 to 14
    bufPnt = 15 -> RX FIFO Buffer

    maskSel = 0    ->    Acceptance Mask 0 register contains mask
    maskSel = 1    ->    Acceptance Mask 1 register contains mask
    maskSel = 2    ->    Acceptance Mask 2 register contains mask
    maskSel = 3    ->    No Mask Selection
    
*/
    Ecan1WriteRxAcptFilter( 1, 0x1FFEFFFF, 1, 1, 0 );

    /*    Mask Configuration

    Ecan1WriteRxAcptMask(int m, long identifierMask, unsigned int mide, unsigned int exide)

    m = 0 to 2 -> Mask Number

    identifier -> SID <10:0> : EID <17:0> 

    mide = 0 -> Match either standard or extended address message if filters match 
    mide = 1 -> Match only message types that correpond to 'exide' bit in filter

    exide = 0 -> Match messages with standard identifier addresses 
    exide = 1 -> Match messages with extended identifier addresses
    
*/
    Ecan1WriteRxAcptMask( 1, 0x1FFFFFFF, 1, 1 );

    /* Enter Normal Mode */
    C1CTRL1bits.REQOP = 0;
    while( C1CTRL1bits.OPMODE != 0 );

    /* ECAN transmit/receive message control */
    C1RXFUL1 = C1RXFUL2 = C1RXOVF1 = C1RXOVF2 = 0x0000;
    C1TR01CONbits.TXEN0 = 1;        /* ECAN1, Buffer 0 is a Transmit Buffer */
    C1TR01CONbits.TXEN1 = 0;        /* ECAN1, Buffer 1 is a Receive Buffer */
    C1TR01CONbits.TX0PRI = 0b11;   /* Message Buffer 0 Priority Level */
    C1TR01CONbits.TX1PRI = 0b11;   /* Message Buffer 1 Priority Level */

	//Unlock PPS Registers
	__builtin_write_OSCCONL(OSCCON & ~(1 << 6));

	TRISFbits.TRISF4 = 1;
	TRISFbits.TRISF5 = 0;

	IN_FN_PPS_C1RX = IN_PIN_PPS_RP100;
	OUT_PIN_PPS_RP101 = OUT_FN_PPS_C1TX;

	//Lock PPS Registers
	__builtin_write_OSCCONL(OSCCON | (1 << 6));
}

/*******************************************************************************
 End of File
*/
