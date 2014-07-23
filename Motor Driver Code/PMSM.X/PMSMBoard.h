/* 
 * File:   PMSMBoard.h
 * Author: Pavlo
 *
 * Created on October 29, 2013, 4:55 PM
 */


#ifndef PMSMBOARD_H
#define	PMSMBOARD_H

#include <xc.h>

#ifdef __33EP256MU806_H
/**
 * @brief Gate Duty Cycle Mapping
 */
#define GL_A_DC       SDC3
#define GH_A_DC       PDC3
#define	GL_B_DC       SDC2
#define GH_B_DC       PDC2
#define GL_C_DC       SDC1
#define GH_C_DC       PDC1

#define TRIS_EN_GATE  TRISGbits.TRISG7
#define TRIS_DC_CAL   TRISEbits.TRISE6
#define TRIS_CS       TRISGbits.TRISG9

#define TRIS_HALL1    TRISCbits.TRISC14
#define TRIS_HALL2    TRISCbits.TRISC13
#define TRIS_HALL3    TRISDbits.TRISD0

#define TRIS_LED1     TRISBbits.TRIB8
#define TRIS_LED2     TRISBbits.TRIB9
#define TRIS_LED3     TRISBbits.TRIB10
#define TRIS_LED4     TRISBbits.TRIB11

#define EN_GATE  LATGbits.LATG7
#define DC_CAL   LATGbits.LATE6
#define CS       LATGbits.LATG9

#define HALL1    PORTCbits.RC14
#define HALL2    PORTCbits.RC13
#define HALL3    PORTDbits.RD0

#define LED1     LATBbits.LATB8
#define LED2     LATBbits.LATB9
#define LED3     LATBbits.LATB10
#define LED4     LATBbits.LATB11
#endif

void UART2Init();
void ClockInit();
void MotorInit();
void TimersInit();
void PinInit();

#endif	/* PMSMBOARD_H */

