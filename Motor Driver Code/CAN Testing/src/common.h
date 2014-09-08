/*******************************************************************************
  Company:
    Microchip Technology Inc.

  File Name:
    common.h

  Summary:
    Contains the prototype structure for the message ID.

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
#ifndef __COMMON_H__
    #define __COMMON_H__

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
    #include <stdint.h>

    #ifdef __cplusplus                  // Provide C++ Compatability
extern "C"
{
        #endif

    // *****************************************************************************
    // *****************************************************************************
    // Section: Constants
    // *****************************************************************************
    // *****************************************************************************
        #define CAN_MSG_DATA    0x01    // message type
        #define CAN_MSG_RTR     0x02    // data or RTR
        #define CAN_FRAME_EXT   0x03    // Frame type
        #define CAN_FRAME_STD   0x04    // extended or standard

    // *****************************************************************************

    // *****************************************************************************

    // Section: Data Types

    // *****************************************************************************

    // *****************************************************************************

    /* message structure in RAM */
    typedef struct
    {
        /* keep track of the buffer status */
        uint8_t     buffer_status;

        /* RTR message or data message */
        uint8_t     message_type;

        /* frame type extended or standard */
        uint8_t     frame_type;

        /* buffer being used to reference the message */
        uint8_t     buffer;

        /* 29 bit id max of 0x1FFF FFFF 
    *  11 bit id max of 0x7FF */
        uint32_t    id;

        /* message data */
        uint8_t     data[8];

        /* received message data length */
        uint8_t     data_length;
    } mID;

        #ifdef __cplusplus  // Provide C++ Compatibility
}

    #endif
#endif

/*******************************************************************************
 End of File
*/
