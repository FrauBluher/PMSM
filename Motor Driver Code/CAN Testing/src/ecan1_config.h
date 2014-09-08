/*******************************************************************************
  ECAN Configuration header file

  Company:
    Microchip Technology Inc.

  File Name:
    ecan1_config.h

  Summary:
    Contains the prototypes for ECAN and DMA initialization and configuration functions.

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
#ifndef __ECAN1_CONFIG_H__
    #define __ECAN1_CONFIG_H__

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
    #include "ecan1drv.h"
    #include <stdint.h>

    #ifdef __cplusplus      // Provide C++ Compatability
extern "C"
{
        #endif

    // *****************************************************************************
    // *****************************************************************************
    // Section: Constants
    // *****************************************************************************
    // *****************************************************************************
    /* CAN Baud Rate Configuration         */
        #define FCAN    40000000
        #define BITRATE 1000000
        #define NTQ     20  // 20 Time Quanta in a Bit Time
        #define BRP_VAL ( (FCAN / (2 * NTQ * BITRATE)) - 1 )

    //#define _HAS_DMA_
    /* CAN Message Buffer Configuration */
        #define ECAN1_MSG_BUF_LENGTH    4

    // *****************************************************************************
    // *****************************************************************************
    // Section: Data Types
    // *****************************************************************************
    // *****************************************************************************
    typedef uint16_t                        ECAN1MSGBUF[ECAN1_MSG_BUF_LENGTH][8];

    //extern ECAN1MSGBUF  ecan1msgBuf __attribute__((space(dma)));
        #if 0
            #ifdef _HAS_DMA_
    __eds__ extern ECAN1MSGBUF ecan1msgBuf  __attribute__( (eds, space(dma)) );
            #else
    __eds__ extern ECAN1MSGBUF ecan1msgBuf  __attribute__( (space(xmemory)) );
            #endif
        #endif
    extern __eds__ uint16_t                 ecan1msgBuf[ECAN1_MSG_BUF_LENGTH][8] __attribute__
        ( (space(eds), aligned(ECAN1_MSG_BUF_LENGTH * 16)) );

    // *****************************************************************************
    // *****************************************************************************
    // Section: Interface Routines
    // *****************************************************************************
    // *****************************************************************************
    /* Function Prototype     */
    extern void                             Ecan1Init( void );
    extern void                             DMA0Init( void );
    extern void                             DMA2Init( void );

        #ifdef __cplusplus  // Provide C++ Compatibility
}

    #endif
#endif

/*******************************************************************************
 End of File
*/
