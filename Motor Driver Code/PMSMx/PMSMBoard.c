#include "PMSMBoard.h"
#include <timer.h>
#include "SPIdsPIC.h"
#include "Uart2.h"
#include "pps.h"
#include "DRV8301.h"
#include "PMSM.h"
#include "PMSMBoard.h"
#include "BasicMotorControl.h"
#include "DMA_Transfer.h"
#include <uart.h>

static MotorInfo motorInformation;
static DRV8301_Info motorDriverInfo;

void InitBoard(CircularBuffer * cB)
{
	ClockInit();
	UART2Init();
	PinInit();
	MotorInit();
	SPI1_Init();
	PMSM_Init(&motorInformation);
	DRV8301_Init(&motorDriverInfo);
	TimersInit();
	putsUART2((unsigned int *) "Initializing DMA...\r\n");
	//DMA1_UART2_Enable_RX(cB);
}

void UART2Init(void)
{
	U2MODEbits.STSEL = 0; // 1-stop bit
	U2MODEbits.PDSEL = 0; // No parity, 8-data bits
	U2MODEbits.ABAUD = 0; // Auto-baud disabled
	U2BRG = 37;
	U2STAbits.UTXISEL0 = 0; // int on last character shifted out tx register
	U2STAbits.UTXISEL1 = 0; // int on last character shifted out tx register
	U2STAbits.URXISEL = 0; // Interrupt after one RX character is received
	U2MODEbits.UARTEN = 1; // Enable UART
	U2STAbits.UTXEN = 1; // Enable UART TX
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
	TRIS_CS = 0;

	TRIS_HALL1 = 1;
	TRIS_HALL2 = 1;
	TRIS_HALL3 = 1;

	//Ensuring that SPI remapped pins' tristates are set correctly.
	TRISEbits.TRISE7 = 1; //MISO
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

	TRISDbits.TRISD4 = 0;

	//Unlock PPS Registers
	__builtin_write_OSCCONL(OSCCON & ~(1 << 6));

	OUT_PIN_PPS_RP68 = OUT_FN_PPS_U2TX; //U2Tx
	IN_FN_PPS_U2RX = IN_PIN_PPS_RP67; //U2Rx
	OUT_PIN_PPS_RP118 = OUT_FN_PPS_SDO1; //SDO
	OUT_PIN_PPS_RP120 = OUT_FN_PPS_SCK1; //SCLK
	IN_FN_PPS_SDI1 = IN_PIN_PPS_RP87; //SDI

	//Lock PPS Registers
	__builtin_write_OSCCONL(OSCCON | (1 << 6));

	TRIS_LED1 = 0;
	TRIS_LED2 = 0;
	TRIS_LED3 = 0;
	TRIS_LED4 = 0;
}

void TimersInit(void)
{
	T2CONbits.TON = 0;
	T2CONbits.TCS = 0;
	T2CONbits.TGATE = 0;
	T2CONbits.TCKPS = 0b11; // Select 1:256 Prescaler
	TMR2 = 0x00;
	PR2 = 0xEFFF;
	IPC1bits.T2IP = 0x01;
	IFS0bits.T2IF = 0;
	IEC0bits.T2IE = 1;
	T2CONbits.TON = 1;
}