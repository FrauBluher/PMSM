/*
 * File:   example_main.c
 * Author: Pavlo Milo Manovi
 *
 *
 * If being used with the CAN enabled PMSM Board obtained at either pavlo.me or off of
 * http://github.com/FrauBluher/ as of v 1.6 the following pins are reserved on the
 * dsPIC33EP256MC506:
 *
 * THIS NEEDS TO BE UPDATED FOR v1.6
 */

#include <xc.h>
#include <string.h>
#include <stdlib.h>
#include <uart.h>
#include <spi.h>
#include <string.h>
#include "DRV8301.h"
#include "SPIdsPIC.h"
#include "PMSM.h"
#include "PMSMBoard.h"
#include "BasicMotorControl.h"
#include "Uart2.h"

_FOSCSEL(FNOSC_FRC & IESO_OFF);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_NONE);
_FWDT(FWDTEN_OFF);
_FICD(ICS_PGD1 & JTAGEN_OFF);


MotorInfo motorInformation;
DRV8301_Info motorDriverInfo;

int main(void)
{
	ClockInit();
	Uart2Init(37);
	PinInit();
	MotorInit();
	SPI2_Init();
	PMSM_Init(&motorInformation);
	DRV8301_Init(&motorDriverInfo);
	TimersInit();

	LED1 = 1;
	LED2 = 1;
	LED3 = 1;
	LED4 = 1;

	while (1) {
		TrapUpdate(900, CCW);
	}

}

void __attribute__((__interrupt__, no_auto_psv)) _T1Interrupt(void)
{
	IFS0bits.T1IF = 0; // Clear Timer1 Interrupt Flag
}

void __attribute__((__interrupt__, no_auto_psv)) _T2Interrupt(void)
{
	DRV8301_Init(&motorDriverInfo);
	IFS0bits.T2IF = 0; // Clear Timer1 Interrupt Flag
}



