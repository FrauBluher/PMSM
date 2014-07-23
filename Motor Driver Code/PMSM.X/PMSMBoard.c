#include "PMSMBoard.h"
#include "SPIdsPIC.h"
#include "pps.h"

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
	U2STAbits.URXISEL = 1; // RX interrupt on every character
	U2STAbits.OERR = 0; // clear overun error

	// U2BRG Register
	// ==============
	U2BRG = 37; //115200

	// Enable the port;
	U2MODEbits.UARTEN = 1; // Enable the port
	U2STAbits.UTXEN = 1; // Enable TX
}

void MotorInit()
{
	/* Set PWM Period on Primary Time Base */
	PTPER = 1000;
	/* Set Phase Shift */
	PHASE1 = 0;
	SPHASE1 = 0;
	PHASE2 = 0;
	SPHASE2 = 0;
	PHASE3 = 0;
	SPHASE3 = 0;
	/* Set Duty Cycles */
	PDC1 = 0;
	SDC1 = 0;
	PDC2 = 0;
	SDC2 = 0;
	PDC3 = 0;
	SDC3 = 0;
	/* Set Dead Time Values */
	DTR1 = DTR2 = DTR3 = 0;
	ALTDTR1 = ALTDTR2 = ALTDTR3 = 0;
	/* Set PWM Mode to Independent */
	IOCON1 = IOCON2 = IOCON3 = 0xCC00;
	//Set unused PWM outputs as GPIO driven
	IOCON4 = 0;
	/* Set Primary Time Base, Edge-Aligned Mode and Independent Duty Cycles */
	PWMCON1 = PWMCON2 = PWMCON3 = 0x0000;
	/* Configure Faults */
	FCLCON1 = FCLCON2 = FCLCON3 = 0x0003;
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

	//Ensuring that SPI remapped pins' tristates are set correctly.
	TRISGbits.TRISE7 = 1; //MISO
	TRISGbits.TRISG6 = 0; //MOSI
	TRISGbits.TRISG8 = 0; //SCLK
	
	TRIS_LED1 = 0;
	TRIS_LED2 = 0;
	TRIS_LED3 = 0;
	TRIS_LED4 = 0;

	//Right now no analog peripherals are being used, so we let digital
	//peripherals take over.
	ANSELB = 0;
	ANSELC = 0;
	ANSELD = 0;
	ANSELE = 0;
	ANSELG = 0;

	//Unlock PPS Registers
	__builtin_write_OSCCONL(OSCCON & ~(1 << 6));

	RPINR20bits.SCK1R = 0;


	//Lock PPS Registers
	__builtin_write_OSCCONL(OSCCON | (1 << 6));


}

void TimersInit(void)
{
	/*  Timer 1 Init Code
	T1CONbits.TON = 0;
	T1CONbits.TCS = 0;
	T1CONbits.TGATE = 0;
	T1CONbits.TCKPS = 0b00; // Select 1:256 Prescaler
	TMR1 = 0x00;
	PR1 = 1;
	IPC0bits.T1IP = 0x02;
	IFS0bits.T1IF = 0;
	IEC0bits.T1IE = 1;
	T1CONbits.TON = 1;
	 */

	T2CONbits.TON = 0;
	T2CONbits.TCS = 0;
	T2CONbits.TGATE = 0;
	T2CONbits.TCKPS = 0b11; // Select 1:256 Prescaler
	TMR2 = 0x00;
	PR2 = 2400;
	IPC1bits.T2IP = 0x01;
	IFS0bits.T2IF = 0;
	IEC0bits.T2IE = 1;
	T2CONbits.TON = 1;
}