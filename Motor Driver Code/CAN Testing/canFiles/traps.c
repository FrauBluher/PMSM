/***********************************************************************
 * This file provides a basic template for writing dsPIC30F trap       *
 * handlers in C language for the C30 compiler                         *
 *                                                                     *
 * Add this file into your MPLAB project. Build your project, program  *
 * the device and run. If any trap occurs during code execution, the   *
 * processor vectors to one of these routines.                         *
 *                                                                     *
 * For additional information about dsPIC architecture and language    *
 * tools, refer to the following documents:                            *
 *                                                                     *
 * MPLAB C30 Compiler User's Guide                        : DS51284    *
 * dsPIC 30F MPLAB ASM30, MPLAB LINK30 and Utilites                    *
 *                                           User's Guide : DS51317    *
 * Getting Started with dsPIC DSC Language Tools          : DS51316    *
 * dsPIC 30F Language Tools Quick Reference Card          : DS51322    *
 * dsPIC 30F 16-bit MCU Family Reference Manual           : DS70046    *
 * dsPIC 30F General Purpose and Sensor Families                       *
 *                                           Data Sheet   : DS70083    *
 * dsPIC 30F/33F Programmer's Reference Manual            : DS70157    *
 *                                                                     *
 * Template file has been compiled with MPLAB C30 v3.00.               *
 *                                                                     *
 ***********************************************************************
 *                                                                     *
 *    Author:                                                          *
 *    Company:                                                         *
 *    Filename:       traps.c                                          *
 *    Date:           04/11/2007                                       *
 *    File Version:   3.00                                             *
 *    Devices Supported:  All PIC24F,PIC24H,dsPIC30F,dsPIC33F devices  *
 *                                                                     *
 **********************************************************************/

#ifdef __dsPIC30F__

        #include "p30fxxxx.h"

#endif

#ifdef __dsPIC33F__

        #include "p33Fxxxx.h"

#endif

#ifdef __PIC24F__

        #include "p24Fxxxx.h"

#endif

#ifdef __PIC24H__

        #include "p24Hxxxx.h"

#endif

#ifdef __dsPIC33E__
        #include "xc.h"
        #include "../../PMSMx/PMSMBoard.h"
#endif

#define _trapISR __attribute__((interrupt,no_auto_psv))

/* ****************************************************************
* Standard Exception Vector handlers if ALTIVT (INTCON2<15>) = 0  *
*                                                                 *
* Not required for labs but good to always include                *
******************************************************************/
void _trapISR _OscillatorFail(void)
{
    LED4 = 0;

        INTCON1bits.OSCFAIL = 0;
        while(1);
}

void _trapISR _AddressError(void)
{
    LED4 = 0;

        INTCON1bits.ADDRERR = 0;
        while(1);
}
//extern unsigned long errAddress;
// void where_was_i(void);
// void __attribute__((interrupt(preprologue("rcall _where_was_i")),no_auto_psv)) _AddressError(void)
// {
//   Nop();   // Set breakpoint here. When hit, variable _errAddress shows the return address
//   Nop();
//   Nop();
// }



void _trapISR _StackError(void)
{
LED4 = 0;

        INTCON1bits.STKERR = 0;
        while(1);
}

void _trapISR _MathError(void)
{
LED4 = 0;
    
        INTCON1bits.MATHERR = 0;
        while(1);
}




/* ****************************************************************
* Alternate Exception Vector handlers if ALTIVT (INTCON2<15>) = 1 *
*                                                                 *
* Not required for labs but good to always include                *
******************************************************************/
void _trapISR _AltOscillatorFail(void)
{
LED4 = 0;

        INTCON1bits.OSCFAIL = 0;
        while(1);
}

void _trapISR _AltAddressError(void)
{
LED4 = 0;

        INTCON1bits.ADDRERR = 0;
        while(1);
}

void _trapISR _AltStackError(void)
{
LED4 = 0;

        INTCON1bits.STKERR = 0;
        while(1);
}

void _trapISR _AltMathError(void)
{
LED4 = 0;
    
        INTCON1bits.MATHERR = 0;
        while(1);
}

void __attribute__ ((interrupt, auto_psv)) _DefaultInterrupt(void)
{
    while(1);
}

