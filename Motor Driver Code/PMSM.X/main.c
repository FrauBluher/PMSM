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

_FOSCSEL(FNOSC_FRC & IESO_OFF & PWMLOCK_OFF);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_NONE);
_FWDT(FWDTEN_OFF);
_FICD(ICS_PGD1 & JTAGEN_OFF);


MotorInfo motorInformation;
DRV8301_Info motorDriverInfo;

int main(void)
{
	int temp;
	ClockInit();
	Uart2Init(37);
	PinInit();
	MotorInit();
	SPI2_Init();
	PMSM_Init(&motorInformation); //Fix Gate Control
	for (temp = 0; temp < 30000; temp++);
	for (temp = 0; temp < 30000; temp++);
	for (temp = 0; temp < 30000; temp++);
	DRV8301_Init(&motorDriverInfo);
	TimersInit();

	LED1 = 1;
	LED2 = 1;
	LED3 = 1;
	LED4 = 1;

	//	For example API use.
	//	uint8_t commandChar;
	//	uint8_t commandSentence[16] = {};
	//	uint8_t i = 0;
	//	uint8_t zero[16] = {};

	while (1) {
		TrapUpdate(900, CCW);

		//An example of how to use the basic motor control API is found below.
		//		if(Uart2ReadByte(&commandChar)) {
		//			if(commandChar == '\n') {
		//				commandSentence[i] = '\0';
		//				if (strcmp((const char *) commandSentence, "s")) {
		//					torque = 0;
		//				} else if (strcmp((const char *) commandSentence, "cw")) {
		//					direction = CW;
		//				} else if (strcmp((const char *) commandSentence, "ccw")) {
		//					direction = CCW;
		//				} else {
		//					uint8_t commanded = atoi((const char *) commandSentence);
		//					if (commanded < 100) {
		//						torque = commanded * 100;
		//					} else {
		//						torque = 0;
		//					}
		//				}
		//				memcpy(commandSentence, &zero, 16);
		//				i = 0;
		//			} else if (i > 4) {
		//				memcpy(commandSentence, &zero, 16);
		//				i = 0;
		//			} else {
		//				commandSentence[i] =  commandChar;
		//				i++;
		//			}
		//		}
	}

}

void __attribute__((__interrupt__, no_auto_psv)) _T1Interrupt(void)
{

#ifdef SINUSOIDAL
	SetPosition();
	SetTorque();
	PMSM_Update();
#else
	//Do something here controls related, who knows!
#endif

	IFS0bits.T1IF = 0; // Clear Timer1 Interrupt Flag
}

void __attribute__((__interrupt__, no_auto_psv)) _T2Interrupt(void)
{
	LED1 = HALL1 ? 1 : 0;
	LED2 = HALL2 ? 1 : 0;
	LED3 = HALL3 ? 1 : 0;

	//Yes, PMSM_Init is supposed to be called here over and over again,
	//explaination in DRV8301.c  This is temporary.
	DRV8301_Init(&motorDriverInfo);
	LED4 ^= 1;
	IFS0bits.T2IF = 0; // Clear Timer1 Interrupt Flag
}



