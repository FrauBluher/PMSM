#include <xc.h>
#include <dma.h>
#include <stdint.h>
#include "DMA_Transfer.h"
#include "CircularBuffer.h"
#include "PMSMBoard.h"

CircularBuffer *uart_CB_Point;
CircularBuffer *spi_CB_Point;
CircularBuffer *can_CB_Point;

uint16_t SPI1RxBuffA[16];
__eds__ uint16_t BufferB __attribute__((eds, space(dma)));
__eds__ uint16_t Ecan1Rx[12][8] __attribute__((eds, space(dma)));
ADCBuffer *ADCBuffPoint;

void DMA0_UART2_Transfer(uint16_t size, uint8_t *SendBuffer)
{
	DMA0CONbits.SIZE = 1; //Byte
	DMA0CONbits.DIR = 1; //RAM-to-Peripheral
	DMA0CONbits.HALF = 0;
	DMA0CONbits.NULLW = 0; //Null write disabled
	DMA0CONbits.AMODE = 0; //Register Indirect with Post-Increment
	DMA0CONbits.MODE = 1;

	DMA0CNT = (size - 1);
	DMA0REQ = 0x001F; // Select UART2 transmitter
	DMA0PAD = (volatile uint16_t) & U2TXREG;
	DMA0STAL = (volatile uint16_t) SendBuffer; //This may need some tweaking~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	DMA0STAH = 0x0000;

	IFS0bits.DMA0IF = 0; // Clear DMA Interrupt Flag
	IEC0bits.DMA0IE = 1; // Enable DMA interrupt
	DMA0CONbits.CHEN = 1; // Enable DMA channel
	DMA0REQbits.FORCE = 1;
}

void DMA1_UART2_Enable_RX(CircularBuffer *cB)
{
	uart_CB_Point = cB;
	//DMA1CON = 0x0000; // Continuous, Ping-Pong Disabled, Periph-RAM
	DMA1CONbits.SIZE = 1; //Byte
	DMA1CONbits.DIR = 0; //Peripheral-to-RAM
	DMA1CONbits.HALF = 0;
	DMA1CONbits.NULLW = 0; //Null write disabled
	DMA1CONbits.AMODE = 1; //Register Indirect without Post-Increment
	DMA1CONbits.MODE = 0; //Continuous, Ping-Pong mode disabled


	DMA1CONbits.MODE = 0; // Continuous, Ping-Pong Disabled
	DMA1CONbits.AMODE = 0; // Register indirect mode, post-increment
	DMA1CNT = 0; // Eight DMA requests
	DMA1REQ = 0x001E; // Select UART2 receiver
	DMA1PAD = (volatile uint16_t) & U2RXREG;
	DMA1STAL = __builtin_dmaoffset(&BufferB);
	DMA1STAH = 0x0000;

	IFS0bits.DMA1IF = 0; // Clear DMA interrupt
	IEC0bits.DMA1IE = 1; // Enable DMA interrupt
	DMA1CONbits.CHEN = 1; // Enable DMA channel
}

void DMA2_SPI_Transfer(uint16_t size, uint16_t *SendBuffer)
{
	DMA2CONbits.SIZE = 0; //Word wide transfer
	DMA2CONbits.DIR = 1; //RAM-to-Peripheral
	DMA2CONbits.HALF = 0;
	DMA2CONbits.NULLW = 0; //Null write disabled
	DMA2CONbits.AMODE = 0; //Register Indirect with Post-Increment
	DMA2CONbits.MODE = 01; //One-Shot, Ping-Pong modes disabled

	DMA2CNT = (size - 1); //16 transfers
	DMA2REQ = 0x0A;
	DMA2PAD = (volatile uint16_t) & SPI1BUF;
	DMA2STAL = (uint16_t) SendBuffer;
	DMA2STAH = 0;

	SPI1BUF = *SendBuffer;

	IFS1bits.DMA2IF = 0; // Clear DMA interrupt
	IEC1bits.DMA2IE = 1; // Enable DMA interrupt
	DMA2CONbits.CHEN = 1; // Enable DMA Channel
	//DMA2REQbits.FORCE = 1;
}

void DMA3_SPI_Enable_RX(CircularBuffer *cB)
{
	spi_CB_Point = cB;
	DMA3CONbits.SIZE = 0; //Word wide transfer
	DMA3CONbits.DIR = 0; //Peripheral-to-RAM
	DMA3CONbits.HALF = 0;
	DMA3CONbits.NULLW = 0; //Null write disabled
	DMA3CONbits.AMODE = 1; //Register Indirect without Post-Increment
	DMA3CONbits.MODE = 0; //Continuous, Ping-Pong mode disabled

	DMA3CNT = 0;
	DMA3REQ = 0x0A;
	DMA3PAD = (volatile uint16_t) & SPI1BUF;
	DMA3STAL = __builtin_dmaoffset(&SPI1RxBuffA);
	DMA3STAH = 0x0000;

	IFS2bits.DMA3IF = 0; // Clear DMA interrupt
	IEC2bits.DMA3IE = 1; // Enable DMA interrupt
	DMA3CONbits.CHEN = 1; // Enable DMA Channel
}

void DMA4_CAN_Transfer(uint16_t size, uint16_t *SendBuffer)
{
	//Will implement later, waiting for the CAN protocol to be defined.
	DMA4CONbits.AMODE = 2; // Continuous mode, single buffer
	DMA4CONbits.MODE = 0; // Peripheral Indirect Addressing
	DMA4PAD = (volatile uint16_t) & C1RXD; // Point to ECAN1 RX register
	DMA4STAL = __builtin_dmaoffset(Ecan1Rx);
	DMA4STAH = 0x0000;
	DMA4CNT = 7; // 8 DMA request (1 buffer, each with 8 words)
	DMA4REQ = 0x22; // Select ECAN1 RX as DMA Request source

	IFS2bits.DMA4IF = 0; // Clear DMA interrupt
	IEC2bits.DMA4IE = 1; // Enable DMA Channel 0 interrupt
	DMA4CONbits.CHEN = 1; // Enable DMA Channel 0
}

void DMA5_CAN_Enable_RX(CircularBuffer *cB)
{
	can_CB_Point = cB;
}

void DMA6_ADC_Enable(ADCBuffer *ADCBuff)
{
	ADCBuffPoint = ADCBuff;

	DMA6CONbits.AMODE = 0; // Configure DMA for Register Indirect/Post Inc.
	DMA6CONbits.MODE = 0; // Configure DMA for Continuous mode no pingpong
	DMA6PAD = (volatile unsigned int) &ADC1BUF0; // Point DMA to ADC1BUF0
	DMA6CNT = 1; // 2 DMA request (2 buffers, each with 1 words)
	DMA6REQ = 13; // Select ADC1 as DMA request source
	DMA6STAL = (volatile uint16_t) ADCBuff;
	DMA6STAH = 0x0000;
	IFS4bits.DMA6IF = 0; // Clear the DMA Interrupt Flag bit
	IEC4bits.DMA6IE = 1; // Set the DMA Interrupt Enable bit
	DMA6CONbits.CHEN = 1; // Enable DMA
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA0Interrupt(void)
{
	IFS0bits.DMA0IF = 0; // Clear the DMA0 Interrupt Flag
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA1Interrupt(void)
{
	CB_WriteByte(uart_CB_Point, U2RXREG);
	IFS0bits.DMA1IF = 0;
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA2Interrupt(void)
{
	IFS1bits.DMA2IF = 0;
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA3Interrupt(void)
{
	//Think about a global interrupt disable here as CB is non reentrant...
	CB_WriteByte(spi_CB_Point, SPI1RxBuffA[0]);
	IFS2bits.DMA3IF = 0;
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA4Interrupt(void)
{
	/*
	 * Process data that gets received using this not in the interrupt, but in
	 * the main loop to make sure that the order of processing doesn't mess up
	 * the operation of the motor driver.  The processing of the received DMA
	 * data should follow as below.
	 *
	 * ProcessData(Ecan1Rx[C1VECbits.ICODE]); // Process received buffer;
	 */

	IFS2bits.DMA4IF = 0;
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA5Interrupt(void)
{
	//Think about a global interrupt disable here as CB is non reentrant...
	CB_WriteByte(can_CB_Point, C1RXD);
	IFS3bits.DMA5IF = 0;
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA6Interrupt(void)
{
	ADCBuffPoint->newData = 1;
	IFS4bits.DMA6IF = 0; // Clear the DMA5 Interrupt Flag
}