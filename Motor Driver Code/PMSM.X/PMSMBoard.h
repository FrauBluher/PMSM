/* 
 * File:   PMSMBoard.h
 * Author: Pavlo
 *
 * Created on October 29, 2013, 4:55 PM
 */


#ifndef PMSMBOARD_H
#define	PMSMBOARD_H

#include <xc.h>

#ifdef __33EP512GM306_H
/**
 * @brief CAN Tristate Mapping
 */
#define TRIS_CANRX TRISAbits.TRISA8
#define TRIS_CANTX TRISBbits.TRISB4

/**
 * @brief GPIO Tristate Mapping
 */
#define TRIS_EN_GATE  TRISGbits.TRISG7
#define TRIS_DC_CAL   TRISGbits.TRISG8
#define TRIS_CS       TRISCbits.TRISC7;
#define TRIS_HALL1    TRISBbits.TRISB8
#define TRIS_HALL2    TRISCbits.TRISC13
#define TRIS_HALL3    TRISBbits.TRISB7
#define TRIS_LED1     TRISCbits.TRISC0
#define TRIS_LED2     TRISCbits.TRISC1
#define TRIS_LED3     TRISCbits.TRISC2
#define TRIS_LED4     TRISCbits.TRISC11

/**
 * @brief Gate Duty Cycle Mapping
 */
#define GL_A_DC       PDC4
#define GH_A_DC       SDC4
#define	GL_B_DC       PDC2
#define GH_B_DC       SDC2
#define GL_C_DC       PDC3
#define GH_C_DC       SDC3

/**
 * @brief GPIO Latch Mapping
 */
#define EN_GATE  LATGbits.LATG7
#define DC_CAL   LATGbits.LATG8
#define CS       LATCbits.LATC7
#define HALL1    PORTBbits.RB8
#define HALL2    PORTCbits.RC13
#define HALL3    PORTBbits.RB7
#define LED1     LATCbits.LATC0
#define LED2     LATCbits.LATC1
#define LED3     LATCbits.LATC2
#define LED4     LATCbits.LATC11
#endif

#ifdef __33EP256MU806_H
#define TRIS_EN_GATE  TRISGbits.TRISG7
#define TRIS_DC_CAL   TRISGbits.TRISG8
#define TRIS_CS       TRISGbits.TRISG9

#define TRIS_HALL1    TRISCbits.TRISC14
#define TRIS_HALL2    TRISCbits.TRISC13
#define TRIS_HALL3    TRISDbits.TRISD0

#define TRIS_LED1     TRISBbits.TRIB8
#define TRIS_LED2     TRISBbits.TRIB9
#define TRIS_LED3     TRISBbits.TRIB10
#define TRIS_LED4     TRISBbits.TRIB11

#define EN_GATE  LATGbits.LATG7
#define DC_CAL   LATGbits.LATG8
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

