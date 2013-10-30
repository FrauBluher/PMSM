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
	//EN_GATE
	TRISDbits.TRISD6 = 0;
	LATDbits.LATD6 = 1;
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

	T2CON = 0; // Ensure Timer 2 is in reset
	IFS0bits.T2IF = 0; // Clear Timer2 interrupt flag status bit
	IPC1bits.T2IP2 = 1; // Set interrupt priority
	IEC0bits.T2IE = 1; // Enable Timer 2 interrupt
	PR2 = 0xF; // Load the timer period value with the prescalar value
	T2CON = 0x8030; // Set Timer2 control register TON = 1, TCKPS1:TCKPS0 = 0b11 (1:256 prescaler)
	T2CONbits.TCKPS = 3; // Set Timer2 control register TON = 1, TCKPS1:TCKPS0 = 0b11 (1:256 prescaler)
	// Use system clock Fosc/2 = 40 MHz. Result is a 156,250 Hz clock.
}