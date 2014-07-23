/*
 * File:   PMSMx.c
 * Author: Pavlo Milo Manovi
 *
 *
 * If being used with the CAN enabled PMSM Board obtained at either pavlo.me or off of
 * http://github.com/FrauBluher/ as of v 1.6 the following pins are reserved on the
 * dsPIC33EP256MC506:
 *
 * THIS NEEDS TO BE UPDATED FOR v1.9
 */

#include <xc.h>
#include <string.h>
#include <stdlib.h>
#include <uart.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "PMSMBoard.h"
#include "BasicMotorControl.h"
#include "CircularBuffer.h"

_FOSCSEL(FNOSC_FRC & IESO_OFF);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_NONE);
_FWDT(FWDTEN_OFF);
_FICD(ICS_PGD1 & JTAGEN_OFF);


CircularBuffer cmdBuf;
uint8_t cBBuf[32];

int main(void)
{
	int i;
	for (i = 0; i < 15000; i++) {
		Nop(); //Let the board catch it's breath...
	}
	CB_Init(&cmdBuf, cBBuf, 32);
	InitBoard(&cmdBuf);

	LED1 = 1;
	LED2 = 1;
	LED3 = 1;
	LED4 = 1;


	T2CONbits.TON = 1;

	while (1) {
		TrapUpdate(990, CW);
	}

}

void __attribute__((__interrupt__, no_auto_psv)) _T2Interrupt(void)
{
	uint8_t message[5];
	static uint8_t spinning;
	spinning++;
	sprintf(message, "%i\r\n", spinning);
	putsUART2(message);
	IFS0bits.T2IF = 0; // Clear Timer1 Interrupt Flag
}
