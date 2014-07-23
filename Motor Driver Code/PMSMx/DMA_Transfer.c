#include <xc.h>
#include <dma.h>
#include <stdint.h>
#include "DMA_Transfer.h"
#include "CircularBuffer.h"

CircularBuffer *cB_Point;
__eds__ unsigned int BufferB __attribute__((eds,space(dma)));

//static unsigned int BufferCount = 0; // Keep record of which buffer contains RX Data

void DMA0_UART2_Transfer(uint16_t size, uint8_t *SendBuffer)
{
	DMA0CON = 0x2001; // One-Shot, Post-Increment, RAM-to-Peripheral
	DMA0CNT = (size - 1);
	DMA0REQ = 0x001F; // Select UART2 transmitter
	DMA0PAD = (volatile unsigned int) &U2TXREG;
	DMA0STAL = (volatile unsigned int) SendBuffer; //This may need some tweaking~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	DMA0STAH = 0x0000;
	IFS0bits.DMA0IF = 0; // Clear DMA Interrupt Flag
	IEC0bits.DMA0IE = 1; // Enable DMA interrupt
}

void DMA1_UART2_Enable_RX(CircularBuffer *cB)
{
	cB_Point = cB;
	DMA1CON = 0x0002; // Continuous, Ping-Pong Disabled, Periph-RAM
	DMA1CONbits.MODE = 0; // Continuous, Ping-Pong Disabled
	DMA1CONbits.AMODE = 0; // Register indirect mode, post-increment
	DMA1CNT = 0; // Eight DMA requests
	DMA1REQ = 0x001E; // Select UART2 receiver
	DMA1PAD = (volatile unsigned int) &U2RXREG;
	//DMA1STAL = &BufferB;
	DMA1STAH = 0x0000;

	IFS0bits.DMA1IF = 0; // Clear DMA interrupt
	IEC0bits.DMA1IE = 1; // Enable DMA interrupt
	DMA1CONbits.CHEN = 1; // Enable DMA channel
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA0Interrupt(void)
{
	IFS0bits.DMA0IF = 0; // Clear the DMA0 Interrupt Flag
}

void __attribute__((__interrupt__, no_auto_psv)) _DMA1Interrupt(void)
{
	CB_WriteByte(cB_Point, U2RXREG);
	IFS0bits.DMA1IF = 0; // Clear the DMA1 Interrupt Flag
}
