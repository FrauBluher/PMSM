#include "PMSMBoard.h"
#include "SPIdsPIC.h"

void UART2Init(void)
{
	U2MODEbits.UARTEN = 0; // Disable the port
	U2MODEbits.USIDL = 0; // Stop on idle
	U2MODEbits.IREN = 0; // No IR decoder
	U2MODEbits.RTSMD = 0; // Ready to send mode (irrelevant)
	U2MODEbits.UEN = 0; // Only RX and TX
	U2MODEbits.WAKE = 1; // Enable at startup
	U2MODEbits.LPBACK = 0; // Disable loopback
	U2MODEbits.ABAUD = 0; // Disable autobaud
	U2MODEbits.URXINV = 0; // Normal operation (high is idle)
	U2MODEbits.PDSEL = 0; // No parity 8 bit
	U2MODEbits.STSEL = 0; // 1 stop bit
	U2MODEbits.BRGH = 0;

	IPC7 = 0x4400;
	// U2STA Register
	// ==============
	U2STAbits.URXISEL = 0; // RX interrupt on every character
	U2STAbits.OERR = 0; // clear overun error

	// U2BRG Register
	// ==============
	U2BRG = 26; //115200

	// Enable the port;
	U2MODEbits.UARTEN = 1; // Enable the port
	U2STAbits.UTXEN = 1; // Enable TX
}

void MotorInit()
{
	/* Set PWM Period on Primary Time Base */
	PTPER = 1000;
	/* Set Phase Shift */
	PHASE4 = 0;
	SPHASE4 = 0;
	PHASE2 = 0;
	SPHASE2 = 0;
	PHASE3 = 0;
	SPHASE3 = 0;
	/* Set Duty Cycles */
	PDC2 = 0;
	SDC2 = 0;
	PDC3 = 0;
	SDC3 = 0;
	PDC4 = 0;
	SDC4 = 0;
	/* Set Dead Time Values */
	DTR4 = DTR2 = DTR3 = 0;
	ALTDTR4 = ALTDTR2 = ALTDTR3 = 0;
	/* Set PWM Mode to Independent */
	IOCON2 = IOCON3 = IOCON4 = 0xCC00;
	//Set unused PWM outputs as GPIO driven
	IOCON1 = 0;
	IOCON5 = 0;
	IOCON6 = 0;
	/* Set Primary Time Base, Edge-Aligned Mode and Independent Duty Cycles */
	PWMCON4 = PWMCON2 = PWMCON3 = 0x0000;
	/* Configure Faults */
	FCLCON4 = FCLCON2 = FCLCON3 = 0x0003;
	/* 1:1 Prescaler */
	PTCON2 = 0x0000;
	/* Enable PWM Module */
	PTCON = 0x8000;

	EN_GATE = 1;
	DC_CAL = 0;
}

void ClockInit(void)
{
	// 140.03 MHz VCO  -- 70 MIPS
	PLLFBD = 74;
	CLKDIVbits.PLLPRE = 0;
	CLKDIVbits.PLLPOST = 0;

	// Initiate Clock Switch to FRC oscillator with PLL (NOSC=0b001)
	__builtin_write_OSCCONH(0x01);

	__builtin_write_OSCCONL(OSCCON | 0x01);

	// Wait for Clock switch to occur
	while (OSCCONbits.COSC != 0b001);

	// Wait for PLL to lock
	while (OSCCONbits.LOCK != 1);
}

void PinInit(void)
{
	// 0 - Output, 1 - Input
	TRIS_EN_GATE = 0;
	TRIS_DC_CAL = 0;
	
	TRIS_HALL1 = 1;
	TRIS_HALL2 = 1;
	TRIS_HALL3 = 1;

	TRISGbits.TRISG6 = 0;
	TRISGbits.TRISG7 = 0;
	TRISGbits.TRISG8 = 0;
	TRISCbits.TRISC8 = 0;
	TRISCbits.TRISC7 = 0;
	TRISCbits.TRISC6 = 0;

	TRIS_LED1 = 0;
	TRIS_LED2 = 0;
	TRIS_LED3 = 0;
	TRIS_LED4 = 0;
	
	ANSELA = 0;
	ANSELB = 0;
	ANSELC = 0;
	ANSELD = 0;
	ANSELE = 0;
	ANSELF = 0;
	ANSELG = 0;

	TRISCbits.TRISC7 = 0; //Pin 51, RP55, RC7
	TRISCbits.TRISC6 = 0; //Pin 50, RP54, RC6
	TRISGbits.TRISG6 = 0; //Pin 4, RP118, RG6
	TRISBbits.TRISB14 = 1; //Pin 3, RPI47, RB14

}

void TimersInit(void)
{
	//Timer1 Init 500Hz.
	T1CONbits.TON = 0;
	T1CONbits.TCS = 0;
	T1CONbits.TGATE = 0;
	T1CONbits.TCKPS = 0b11; // Select 1:256 Prescaler
	TMR1 = 0x00;
	PR1 = 400;
	IPC0bits.T1IP = 0x01;
	IFS0bits.T1IF = 0;
	IEC0bits.T1IE = 1;
	T1CONbits.TON = 1;

	T2CONbits.TON = 0;
	T2CONbits.TCS = 0;
	T2CONbits.TGATE = 0;
	T2CONbits.TCKPS = 0b11; // Select 1:256 Prescaler
	TMR2 = 0x00;
	PR2 = 20;
	IPC1bits.T2IP = 0x01;
	IFS0bits.T2IF = 0;
	IEC0bits.T2IE = 1;
	T2CONbits.TON = 1;
}