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
#include "DRV8301.h"
#include "SPIdsPIC.h"
#include "PMSM.h"
#include "PMSMBoard.h"

_FOSCSEL(FNOSC_FRC & IESO_OFF);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_NONE);
_FWDT(FWDTEN_OFF);
_FICD(ICS_PGD2);


MotorInfo motorInformation;
DRV8301_Info motorDriverInfo;

int main(void)
{
	ClockInit();
	PinInit();
	PMSM_Init(&motorInformation); //Fix Gate Control
	TimersInit();
	SPI2_Init();
	DRV8301_Init(&motorDriverInfo);
	MotorInit();

	while (1) {
	};
	//Sit and Spin
}

/* Since we're just worried about getting data off of the IMU at a constant time
 * interval, we're going to just put it all of the stringification/sensing/sending
 * in this interrupt.  Usually a no-no, but this is fine.  Just don't use this in any
 * code that has any other timing requirements.
 */
void __attribute__((__interrupt__, no_auto_psv)) _T1Interrupt(void)
{
	PDC1 = 0;
	PDC2 = 0;
	PDC3 = 0;

	IFS0bits.T1IF = 0; // Clear Timer1 Interrupt Flag
}

void __attribute__((__interrupt__, no_auto_psv)) _T2Interrupt(void)
{
	IFS0bits.T2IF = 0; // Clear Timer1 Interrupt Flag
}



