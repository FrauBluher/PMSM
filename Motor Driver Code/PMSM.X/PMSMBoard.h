/* 
 * File:   PMSMBoard.h
 * Author: Pavlo
 *
 * Created on October 29, 2013, 4:55 PM
 */


#ifndef PMSMBOARD_H
#define	PMSMBOARD_H

#include <xc.h>

void UART2Init();
void ClockInit();
void MotorInit();
void TimersInit();
void PinInit();

#endif	/* PMSMBOARD_H */

