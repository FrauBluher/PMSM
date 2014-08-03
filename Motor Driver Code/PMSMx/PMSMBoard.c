#include "PMSMBoard.h"
#include <timer.h>
#include "Uart2.h"
#include "pps.h"
#include "DRV8301.h"
#include "PMSM.h"
#include "PMSMBoard.h"
#include "BasicMotorControl.h"
#include "DMA_Transfer.h"
#include "SPIdsPIC.h"
#include <uart.h>

_FOSCSEL(FNOSC_FRC & IESO_OFF);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_NONE);
_FWDT(FWDTEN_OFF);
_FICD(ICS_PGD1 & JTAGEN_OFF);

static MotorInfo motorInformation;
static DRV8301_Info motorDriverInfo;
static InitStatus initInfo = {};

void UART2Init(void);
void ClockInit(void);
void MotorInit(void);
void TimersInit(void);
void PinInit(void);
void EventCheckInit(void *eventCallback);

void (*eventCallbackFcn)(void);

void InitBoard(CircularBuffer *cB, CircularBuffer *spi_cB, void *eventCallback)
{
	if (!initInfo.initReg) {

		int i;
		for (i = 0; i < 15000; i++) {
			Nop(); //Let the DRV catch it's breath...
		}

		ClockInit();
		UART2Init();
		PinInit();
		MotorInit();

		SPI1_Init();
		{
			DMA2REQbits.FORCE = 1;
			while (DMA2REQbits.FORCE == 1);
			CS = 1;
		}

		PMSM_Init(&motorInformation);
		DMA1_UART2_Enable_RX(cB);
		DMA3_SPI_Enable_RX(spi_cB);
		DRV8301_Init(&motorDriverInfo);
		EventCheckInit(eventCallback);
		TimersInit();

		putsUART2((unsigned int *) "Initialization Complete.\r\n");


		//		if (!(initInfo.ClockInited & initInfo.EventCheckInited
		//			& initInfo.MotorInited & initInfo.PinInited
		//			& initInfo.TimersInited & initInfo.UARTInited)) {
		//			while (1);
		//		}
	} else {
		while (1); //Crash and burn.
	}
}

void UART2Init(void)
{
	if (1) { //!(initInfo.UARTInited & 0x01)) {
		U2MODEbits.STSEL = 0; // 1-stop bit
		U2MODEbits.PDSEL = 0; // No parity, 8-data bits
		U2MODEbits.ABAUD = 0; // Auto-baud disabled
		U2MODEbits.BRGH = 1; // High speed UART mode...
		U2BRG = 37; //37 for 115200 on BRGH 0, 460800 on BRGH 1, 921600 = 18
		//BRGH = 0, BRG = 18 for 230400
		U2STAbits.UTXISEL0 = 0; // int on last character shifted out tx register
		U2STAbits.UTXISEL1 = 0; // int on last character shifted out tx register
		U2STAbits.URXISEL = 0; // Interrupt after one RX character is received
		U2MODEbits.UARTEN = 1; // Enable UART
		U2STAbits.UTXEN = 1; // Enable UART TX

		initInfo.UARTInited = 1;
	} else {
		while (1);
	}
}

void MotorInit()
{
	if (1) { //!(initInfo.UARTInited & 0x01)) {!(initInfo.MotorInited & 0x02)) {
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

		initInfo.MotorInited = 1;
	} else {
		while (1);
	}
}

void ClockInit(void)
{
	if (1) { //!(initInfo.UARTInited & 0x01)) {!(initInfo.ClockInited & 0x04)) {
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

		initInfo.ClockInited = 1;
	} else {
		while (1);
	}
}

void PinInit(void)
{
	if (1) { //!(initInfo.UARTInited & 0x01)) {!(initInfo.PinInited & 0x08)) {
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

		//Set up Change Notify Interrupt
		CNENCbits.CNIEC14 = 1; // Enable RC14 pin for interrupt detection
		CNENCbits.CNIEC13 = 1; // Enable RC13
		CNENDbits.CNIED0 = 1;

		IEC1bits.CNIE = 1; // Enable CN interrupts
		IFS1bits.CNIF = 0; // Reset CN interrupt

		HALL1;
		HALL2;
		HALL3;

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

		initInfo.PinInited = 1;
	} else {
		while (1);
	}
}

void TimersInit(void)
{
	if (1) { //!(initInfo.UARTInited & 0x01)) {!(initInfo.TimersInited & 0x10)) {
		T3CONbits.TON = 0; // Stop any 16-bit Timer3 operation
		T2CONbits.TON = 0; // Stop any 16/32-bit Timer3 operation
		T2CONbits.T32 = 1; // Enable 32-bit Timer mode
		T2CONbits.TCS = 0; // Select internal instruction cycle clock
		T2CONbits.TGATE = 0; // Disable Gated Timer mode
		T2CONbits.TCKPS = 0b01; // Select 1:8 Prescaler
		TMR3 = 0x00; // Clear 32-bit Timer (msw)
		TMR2 = 0x00; // Clear 32-bit Timer (lsw)
		PR3 = 0xFFFF; // Load 32-bit period value (msw)
		PR2 = 0xFFFF; // Load 32-bit period value (lsw)
		IPC2bits.T3IP = 0x01; // Set Timer3 Interrupt Priority Level
		IFS0bits.T3IF = 0; // Clear Timer3 Interrupt Flag
		IEC0bits.T3IE = 1; // Enable Timer3 interrupt
		T2CONbits.TON = 1; // Start 32-bit Timer

		T7CONbits.TON = 0;
		T7CONbits.TCS = 0;
		T7CONbits.TGATE = 0;
		T7CONbits.TCKPS = 0b11; // Select 1:256 Prescaler
		TMR7 = 0x00;
		PR7 = 0x0037; //Approximately 5kHz... 0x0112 For 1kHz  0x0037 for 5kHz
		IPC12bits.T7IP = 0x01;
		IFS3bits.T7IF = 0;
		IEC3bits.T7IE = 1;
		T7CONbits.TON = 1;

		initInfo.TimersInited = 1;
	} else {
		while (1);
	}
}

void EventCheckInit(void *eventCallback)
{
	if (1) { //!(initInfo.UARTInited & 0x01)) {!(initInfo.EventCheckInited & 0x20)) {
		eventCallbackFcn = eventCallback;

		initInfo.EventCheckInited = 1;
	} else {
		while (1);
	}
}

void __attribute__((__interrupt__, no_auto_psv)) _T7Interrupt(void)
{
	eventCallbackFcn();
	IFS3bits.T7IF = 0; // Clear Timer1 Interrupt Flag
}

void __attribute__((__interrupt__, no_auto_psv)) _T3Interrupt(void)
{
	/* Interrupt Service Routine code goes here */
	IFS0bits.T3IF = 0; //Clear Timer3 interrupt flag
}