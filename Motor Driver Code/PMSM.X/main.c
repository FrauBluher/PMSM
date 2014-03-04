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
#include <spi.h>
#include "PMSMBoard.h"

_FOSCSEL(FNOSC_FRC & IESO_OFF & PWMLOCK_OFF);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_NONE);
_FWDT(FWDTEN_OFF);
_FICD(ICS_PGD1 & JTAGEN_OFF);


MotorInfo motorInformation;
DRV8301_Info motorDriverInfo;

int main(void)
{
	int i;
	ClockInit();
	PinInit();
	MotorInit();
	SPI3_Init();
	TimersInit();
	for (i = 0; i < 20; i++) {
		WriteSPI3(0xDEAD);
		while (SPI3STATbits.SPITBF);

	}
	PMSM_Init(&motorInformation); //Fix Gate Control
	DRV8301_Init(&motorDriverInfo);

	LED1 = 1;
	LED2 = 1;
	LED3 = 1;
	LED4 = 1;

	while (1) {
	};
	//Sit and Spin
}

void __attribute__((__interrupt__, no_auto_psv)) _T1Interrupt(void)
{
	IFS0bits.T1IF = 0; // Clear Timer1 Interrupt Flag
}

void __attribute__((__interrupt__, no_auto_psv)) _T2Interrupt(void)
{
	int torque = 500;
	if (HALL1 && HALL2 && !HALL3) {
		GH_A_DC = 0;
		GL_A_DC = 0;
		GH_B_DC = torque;
		GL_B_DC = 0;
		GH_C_DC = 0;
		GL_C_DC = torque;
	} else if (!HALL1 && HALL2 && !HALL3) {
		GH_A_DC = 0;
		GL_A_DC = torque;
		GH_B_DC = torque;
		GL_B_DC = 0;
		GH_C_DC = 0;
		GL_C_DC = 0;
	} else if (!HALL1 && HALL2 && HALL3) {
		GH_A_DC = 0;
		GL_A_DC = torque;
		GH_B_DC = 0;
		GL_B_DC = 0;
		GH_C_DC = torque;
		GL_C_DC = 0;
	} else if (!HALL1 && !HALL2 && HALL3) {
		GH_A_DC = 0;
		GL_A_DC = 0;
		GH_B_DC = 0;
		GL_B_DC = torque;
		GH_C_DC = torque;
		GL_C_DC = 0;
	} else if (HALL1 && !HALL2 && HALL3) {
		GH_A_DC = torque;
		GL_A_DC = 0;
		GH_B_DC = 0;
		GL_B_DC = torque;
		GH_C_DC = 0;
		GL_C_DC = 0;
	} else if (HALL1 && HALL2 && HALL3) {
		GH_A_DC = torque;
		GL_A_DC = 0;
		GH_B_DC = 0;
		GL_B_DC = 0;
		GH_C_DC = 0;
		GL_C_DC = torque;
	}
	//	SetPosition();
	//	SetTorque();
	//	PMSM_Update();
	DRV8301_UpdateStatus();

	LED2 ^= 1;
	IFS0bits.T2IF = 0; // Clear Timer1 Interrupt Flag
}



