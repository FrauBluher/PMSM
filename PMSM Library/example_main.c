/* 
 * File:   example_main.c
 * Author: pavlo
 *
 * Created on September 4, 2013, 10:17 AM
 *
 * If being used with the CAN enabled PMSM Board obtained at either pavlo.me or off of
 * http://github.com/FrauBluher/ as of v 1.4 the following pins are reserved on the
 * dsPIC33EP256MC506:
 *
 * - PIN FUNCTIONS - PIN # - USAGE
 * - RPI44/PWM2H/RB12 - Pin 62 - PWM2
 * - RP42/PWM3H/RB10 - Pin 60 - PWM3
 * - RP97/RF1 - PIN 59 - CANTX (VIA PPS)
 * - RPI96/RF0 - PIN 58 - CANRX (VIA PPS)
 * - RD6 - PIN 54 - PWRGD
 * - RD5 - PIN 53 - OCTW
 * - RP56/RC8 - PIN 52 - FAULT
 * - RP55/RC7 - PIN 51 - GAIN
 * - RP54/RC6 - PIN 50 - EN_GATE
 * - TMS/ASDA1/RP41/RB9 - PIN 49 - DC_CAL
 * - TP40/T4CK/ACL1/RB8 - PIN 48 - LED1
 * - RC13 - PIN 47 - LED2
 * - RP39/INT0/RB7 - PIN 46 - LED3
 * - RPI58/RC10 - PIN 45 - LED4
 * - PGEC2/RP38/RB6 - PIN 44 - PGC
 * - PGED2/RP37/RB5 - PIN 43 - PGD
 * - SDA1/RPI52/RC4 - PIN 36 - EN_A
 * - SCK1/RPI51/RC3 - PIN 35 - EN_B
 * - SDI1/RPI25/RA9 - PIN 34 - EN_C
 * - RPI46/PWM1H/RB14 - PIN 2 - PWM1
 * - AN0/OA2OUT/RA0 - PIN 13 - CRNT1 (Current Sens)
 * - AN1/C2IN1+/RA1 - PIN 14 - CRNT2 (Current Sens)
 *
 *
 * Pins connected to solderjumpers allow for specific ID's to be set on a CAN network with
 * one unified compiled image on multiple PMSM boards. (2^5 Unique ID's)
 *
 * - Digital Pin - SJ
 * - RB15 - SJ1
 * - RG6 - SJ4
 * - RG7 - SJ5
 * - RG8 - SJ6
 * - RG9 - SJ7
 *
 *
 * The following pins and peripherals are available on headers JP1, JP2, and JP5:
 *
 * - PIN FUNCTIONS - PIN # - HEADER,#
 * - AN10/RPI28/RA12 - PIN 11 - JP5,2
 * - AN8/RPI27/RA11 - PIN 12 - JP5,3
 * - AN4/RPI34/RB2 - PIN 17 - JP5,4
 * - AN5/RP35/RB3 - PIN 18 - JP5,5
 *
 * - AN3/OA1OUT/RPI33/STED1/RB1 - PIN 16 - JP2,2
 * - AN6/OA3OUT/C4IN1+/OCFB/RC0 - PIN 21 - JP2,3
 * - AN7/C3IN1-/C4IN1+/RC1 - PIN 22 - JP2,4
 * - AN8/C3IN1+/Y1RTS/BCLK1/FLT3/RC2 - PIN 23 - JP2,5
 *
 * - AN12/C2IN2-/U2RTS/BCLK2/RE12 - PIN 27 - JP1,1
 * - AN13/C3IN20/U2CTS/RE13 - PIN 28 - JP1,2
 * - AN14/RPI94/RE14 - PIN 29 - JP1,3
 * - AN14/RPI95/RE15 - PIN 30 - JP1,4
 * - SDA2/RPI24/RA8 - PIN 31 - JP1,5
 * - FLT32/SCL2/RPI36/RB4 - PIN 32 - JP1,6
 *
 * --Note: RPIx pins can only be remapped to be a peripheral input, while RPx function as I/O.
 */

#include <xc.h>
#include <stdio.h>
#include <stdlib.h>
#include "PMSM.h"

#define LED1 LATBbits.LATB8
#define LED2 LATCbits.LATC13
#define LED3 LATBbits.LATC7
#define LED4 LATCbits.LATC10

#if defined(__dsPIC33EP256MC506__)
_FOSCSEL(FNOSC_FRC & IESO_OFF);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_NONE);
_FWDT(FWDTEN_OFF);
_FICD(ICS_PGD2);
#endif

#if defined(__dsPIC33FJ64GS504__)
_FOSCSEL(FNOSC_FRC);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_XT);
_FWDT(FWDTEN_OFF);
_FICD(JTAGEN_OFF & ICS_PGD1);
#endif

#if defined(__dsPIC33FJ128MC802__)
_FOSCSEL(FNOSC_FRC);
_FOSC(FCKSM_CSECMD & OSCIOFNC_OFF & POSCMD_XT);
_FWDT(FWDTEN_OFF);
_FICD(JTAGEN_OFF & ICS_PGD3);
#endif

void MotorInit(void);
void TimersInit(void);
void ClockInit(void);
void DigitalPinsInit(void);

MotorInfo motorInformation;

int main(void) {
    ClockInit();
    DigitalPinsInit();
    MotorInit();
    TimersInit();

    if (!PMSM_Init(&motorInformation)) {
        while (1); //Crash and burn if init fails.
    }

    GateControl(1);
    //Set torque and field weakening value here.

    while (1) {
    	//State machine goes here.
    	
    	//Control position of motor with the PMSM library and feed back the QEI counter value into the control loop.
    	//512 count encoder can be turned into a 2048 count encoder with the QEI peripheral.  If the motor has 6 poles,
    	//two rotations from 0 - 2pi are required to spin the motor once.  That means that the base step commanded position
    	//of the motor should be 2pi / 1024.  Unless of course you want to interpolate position between steps using estimated
    	//speed.
    }
}

void MotorInit() {
#if defined(__dsPIC33FJ64GS504__)
    PTCONbits.PTEN = 0;

    /* Setup for the Auxiliary clock to use the FRC as the REFCLK */
    /* ((FRC * 16) / APSTSCLR) = (7.49 * 16) / 1 = 119.84 MHz */
    ACLKCONbits.FRCSEL = 1; /* FRC is input to Auxiliary PLL */
    ACLKCONbits.SELACLK = 1; /* Auxiliary Oscillator provides the clock
	source */
    ACLKCONbits.APSTSCLR = 7; /* Divide Auxiliary clock by 1 */
    ACLKCONbits.ENAPLL = 1; /* Enable Auxiliary PLL */
    while (ACLKCONbits.APLLCK != 1); /* Wait for Auxiliary PLL to Lock */

    //setup PWM ports
    PWMCON1bits.ITB = 0; /* PTPER provides the PWM time period value */
    PWMCON2bits.ITB = 0; /* PTPER provides the PWM time period value */
    PWMCON3bits.ITB = 0; /* PTPER provides the PWM time period value */
    PWMCON4bits.ITB = 0; /* PTPER provides the PWM time period value */
    PWMCON5bits.ITB = 0; /* PTPER provides the PWM time period value */
    PWMCON6bits.ITB = 0; /* PTPER provides the PWM time period value */

    IOCON1bits.PENH = 1;
    IOCON2bits.PENH = 1;
    IOCON3bits.PENH = 1;
    IOCON4bits.PENH = 1;
    IOCON5bits.PENH = 1;
    IOCON6bits.PENH = 1;

    //Setup desired frequency by setting period for 1:64 prescaler
    PTPER = 10100;
    PHASE1 = 0;
    PHASE2 = 0;
    PHASE3 = 0;
    PHASE4 = 0;
    PHASE5 = 0;
    PHASE6 = 0;

    SetDutyCycle(0, 0, 0, 0, 0, 0);

    PTCONbits.PTEN = 1;
#endif

#if defined(__dsPIC33EP256MC506__)
    /* Set PWM Periods on PHASEx Registers */
    SPHASE1 = 10000;
    SPHASE2 = 10000;
    SPHASE3 = 10000;

    /* Set Duty Cycles */
    SDC1 = 0;
    SDC2 = 0;
    SDC3 = 0;

    /* Set Dead Time Values */
    DTR1 = 0;
    DTR2 = 0;
    DTR3 = 0;
    ALTDTR1 = 0;
    ALTDTR2 = 0;
    ALTDTR3 = 0;

    /* Set PWM Mode to Independent */
    IOCON1 = 0xCC00;
    IOCON2 = 0xCC00;
    IOCON3 = 0xCC00;

    /* Set Independent Time Bases, Center-Aligned Mode and Independent Duty Cycles */
    PWMCON1 = 0x0204;
    PWMCON2 = 0x0204;
    PWMCON3 = 0x0204;

    /* Configure Faults */
    FCLCON1 = 0x0003;
    FCLCON2 = 0x0003;
    FCLCON3 = 0x0003;

    /* 1:1 Prescaler */
    PTCON2 = 0x0000;

    /* Enable PWM Module */
    PTCON = 0x8000;
#endif

#if defined(__dsPIC33FJ128MC802__)
    //setup PWM ports
    PWM1CON1 = 0; //clear all bits (use defaults)
    PWM1CON1bits.PMOD1 = 0; //PWM1Ly,PWM1Hy are in independent running mode
    PWM1CON1bits.PEN1L = 0; //PWM1L1 NORMAL I/O
    PWM1CON1bits.PEN1H = 1; //PWM1H1 PWM OUTPUT

    PWM1CON1bits.PMOD2 = 0;
    PWM1CON1bits.PEN2L = 0;
    PWM1CON1bits.PEN2H = 1;

    PWM2CON1 = 0;
    PWM2CON1bits.PMOD1 = 0;
    PWM2CON1bits.PEN1L = 0;
    PWM2CON1bits.PEN1H = 1;

    P1TCON = 0; //clear all bits (use defaults)
    P1TCONbits.PTMOD = 0b00; //Free-runing mode
    P1TCONbits.PTCKPS = 0b11; // 1:64 prescaler

    P2TCON = 0; //clear all bits (use defaults)
    P2TCONbits.PTMOD = 0b00; //Free-runing mode
    P2TCONbits.PTCKPS = 0b11; // 1:64 prescaler


    //Setup desired frequency by setting period for 1:64 prescaler
    P1TPER = (FCY / 64 / (MOTOR_PWM_FREQ + 170)) - 1;
    P2TPER = (FCY / 64 / (MOTOR_PWM_FREQ + 170)) - 1;

    SetDutyCycle(0, 0, 0);

    //ENABLE PWM1/2
    P1TMR = 0;
    P2TMR = 0;
    P1TCONbits.PTEN = 1;
    P2TCONbits.PTEN = 1;
#endif
}

void ClockInit(void) {
#if defined(__dsPIC33EP256MC506__)

    PLLFBD = 74; // 140.03 MHz VCO  -- 70 MIPS
    CLKDIVbits.PLLPRE = 0;
    CLKDIVbits.PLLPOST = 0;

    // Initiate Clock Switch to FRC oscillator with PLL (NOSC=0b001)
    __builtin_write_OSCCONH(0x01);

    __builtin_write_OSCCONL(OSCCON | 0x01);

    // Wait for Clock switch to occur
    while (OSCCONbits.COSC != 0b001);

    // Wait for PLL to lock
    while (OSCCONbits.LOCK != 1);
#endif

#if defined(__dsPIC33FJ128MC802__)
    PLLFBD = 38; // M = 40 MIPS
    CLKDIVbits.PLLPOST = 0; // N1 = 2
    CLKDIVbits.PLLPRE = 0; // N2 = 2
    OSCTUN = 0;
    RCONbits.SWDTEN = 0;

    __builtin_write_OSCCONH(0x01); // Initiate Clock Switch to Primary (3?)

    __builtin_write_OSCCONL(0x01); // Start clock switching

    while (OSCCONbits.COSC != 0b001); // Wait for Clock switch to occur

    while (OSCCONbits.LOCK != 1) {
    };
#endif

#if defined(__dsPIC33FJ64GS504__)
    PLLFBD = 52; // M = 49.75 MIPS
    CLKDIVbits.PLLPOST = 2; // N1 = 2
    CLKDIVbits.PLLPRE = 0; // N2 = 2
    OSCTUN = 0;
    RCONbits.SWDTEN = 0;

    __builtin_write_OSCCONH(0x01); // Initiate Clock Switch to Primary (3?)

    __builtin_write_OSCCONL(0x01); // Start clock switching

    while (OSCCONbits.COSC != 0b001); // Wait for Clock switch to occur

    while (OSCCONbits.LOCK != 1) {
    };
#endif
}

void TimersInit(void) {
    T2CON = 0; // Ensure Timer 2 is in reset
    IFS0bits.T2IF = 0; // Clear Timer2 interrupt flag status bit
    IPC1bits.T2IP2 = 1; // Set interrupt priority
    IEC0bits.T2IE = 1; // Enable Timer 2 interrupt
    PR2 = 0xF; // Load the timer period value with the prescalar value
    T2CON = 0x8030; // Set Timer2 control register TON = 1, TCKPS1:TCKPS0 = 0b11 (1:256 prescaler)

    T2CONbits.TCKPS = 3; // Set Timer2 control register TON = 1, TCKPS1:TCKPS0 = 0b11 (1:256 prescaler)
    // Use system clock Fosc/2 = 40 MHz. Result is a 156,250 Hz clock.
}

void DigitalPinsInit() {
    TRISDbits.TRISD6 = 1; // PWRGD
    TRISDbits.TRISD5 = 1; // OCTW
    TRISCbits.TRISC8 = 1; // FAULT
    TRISCbits.TRISC7 = 0; // GAIN
    TRISCbits.TRISC6 = 0; // EN_GATE
    TRISBbits.TRISB9 = 0; // DC_CAL
    TRISBbits.TRISB8 = 0; // LED1
    TRISCbits.TRISC13 = 0; // LED2
    TRISBbits.TRISB7 = 0; // LED3
    TRISCbits.TRISC10 = 0; // LED4
    TRISBbits.TRISB14 = 0; // PWM1 Out
    TRISBbits.TRISB12 = 0; // PWM2 Out
    TRISBbits.TRISB10 = 0; // PWM3 Out

    ANSELA = 0x0;
    ANSELB = 0x0;
    ANSELC = 0x0;
    ANSELE = 0x0;



    //CAN
    TRISFbits.TRISF1 = 0; //TX

    _RP97R = 0xE; //TX
    RPINR26bits.C1RXR = 96; //RX

    _RP56R = 0;
    _RP55R = 0;
    _RP54R = 0;
    _RP41R = 0;
    _RP42R = 0;
    _RP118R = 0;
    _RP120R = 0;
    _RP39R = 0;
    _RP40R = 0;

    CVRCONbits.CVR1OE = 0;
    I2C1CONbits.I2CEN = 0;

    ANSELAbits.ANSA0 = 1;
    ANSELAbits.ANSA1 = 1;

    CM1CONbits.CEN = 0;
    CM2CONbits.CEN = 0;
    CM3CONbits.CEN = 0;

}

void __attribute__((interrupt, auto_psv)) _T2Interrupt(void) {
    IEC0bits.T2IE = 0;

    PMSM_Update();

    SDC1 = motorInformation.t1;
    SDC2 = motorInformation.t2;
    SDC3 = motorInformation.t3;

    IEC0bits.T2IE = 1;
    IFS0bits.T2IF = 0;
}
