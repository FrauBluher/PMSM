#include "CircularBuffer.h"
#include "Uart2.h"
#include <xc.h>
#include <uart.h>

#define BAUDRATE    9600
#define BRGVAL      ((FCY / BAUDRATE) / 16 ) - 1

static CircularBuffer uart2RxBuffer;
static uint8_t U2RxBuf[1024];
static CircularBuffer uart2TxBuffer;
static uint8_t u2TxBuf[1024];

/*
 * Private functions.
 */
void Uart2StartTransmission(void);

/**
 * Initialization function for the UART2 peripheral. Should be called in initialization code for the
 * model. This function configures the UART for whatever baud rate is specified. It also configures
 * two circular buffers for transmission and reception.
 *
 * This function can be called again to re-initialize the UART. This clears all relevant registers
 * and reinitializes values to 0.
 */
void Uart2Init(uint16_t brgRegister)
{
	// First initialize the necessary circular buffers.
	CB_Init(&uart2RxBuffer, U2RxBuf, sizeof(U2RxBuf));
	CB_Init(&uart2TxBuffer, u2TxBuf, sizeof(u2TxBuf));

	// If the UART was already opened, close it first. This should also clear the transmit/receive
	// buffers so we won't have left-over data around when we re-initialize, if we are.
	CloseUART2();

	// Configure and open the port.
	OpenUART2(
		UART_EN & UART_IDLE_CON & UART_IrDA_DISABLE &
		UART_MODE_FLOW & UART_UEN_00 & UART_EN_WAKE &
		UART_DIS_LOOPBACK & UART_DIS_ABAUD & UART_NO_PAR_8BIT &
		UART_UXRX_IDLE_ONE & UART_BRGH_SIXTEEN & UART_1STOPBIT,
		UART_INT_TX_LAST_CH & UART_IrDA_POL_INV_ZERO &
		UART_SYNC_BREAK_DISABLED & UART_TX_ENABLE &
		UART_INT_RX_CHAR & UART_ADR_DETECT_DIS &
		UART_RX_OVERRUN_CLEAR, brgRegister
		);

	// Setup interrupts for proper UART communication. Enable both TX and RX interrupts at
	// priority level 6 (arbitrary).
	ConfigIntUART2(UART_RX_INT_EN & UART_RX_INT_PR6 &
		UART_TX_INT_EN & UART_TX_INT_PR6);
}

void Uart2ChangeBaudRate(uint16_t brgRegister)
{
	uint8_t utxen = U2STAbits.UTXEN;

	// Disable the port;
	U2MODEbits.UARTEN = 0;

	// Change the BRG register to set the new baud rate
	U2BRG = brgRegister;

	// Enable the port restoring the previous transmission settings
	U2MODEbits.UARTEN = 1;
	U2STAbits.UTXEN = utxen;
}

/**
 * This function actually initiates transmission. It
 * attempts to start transmission with the first element
 * in the queue if transmission isn't already proceeding.
 * Once transmission starts the interrupt handler will
 * keep things moving from there. The buffer is checked
 * for new data and the transmission buffer is checked that
 * it has room for new data before attempting to transmit.
 */
void Uart2StartTransmission(void)
{
	while (uart2TxBuffer.dataSize > 0 && !U2STAbits.UTXBF) {
		// A temporary variable is used here because writing directly into U2TXREG causes some weird issues.
		uint8_t c;
		CB_ReadByte(&uart2TxBuffer, &c);

		// We process the char before we try to send it in case writing directly into U2TXREG has
		// weird side effects.
		U2TXREG = c;
	}
}

int Uart2ReadByte(uint8_t *datum)
{
	return CB_ReadByte(&uart2RxBuffer, datum);
}

/**
 * This function supplements the Uart2WriteData() function by also
 * providing an interface that only enqueues a single byte.
 */
void Uart2WriteByte(uint8_t datum)
{
	CB_WriteByte(&uart2TxBuffer, datum);
	Uart2StartTransmission();
}

/**
 * This function enqueues all bytes in the passed data character array according to the passed
 * length.
 */
int Uart2WriteData(const void *data, size_t length)
{
	int success = CB_WriteMany(&uart2TxBuffer, data, length, false);

	Uart2StartTransmission();

	return success;
}

void _ISR _U2RXInterrupt(void)
{
	// Make sure if there's an overflow error, then we clear it. While this destroys 5 bytes of data,
	// it's like the whole message these bytes are a part of is missing more bytes, and irrecoverably
	// corrupt, so we don't worry about it.
	if (U2STAbits.OERR == 1) {
		U2STAbits.OERR = 0;
	}

	// Keep receiving new bytes while the buffer has data.
	char c;
	while (U2STAbits.URXDA == 1) {
		// If there's a framing or parity error for the current UART byte, read the data but ignore
		// it. Only if there isn't an error do we actually add the value to our circular buffer.
		if (U2STAbits.FERR == 1 && U2STAbits.PERR) {
			c = U2RXREG;
		} else {
			c = U2RXREG;
			CB_WriteByte(&uart2RxBuffer, (uint8_t) c);
		}
	}

	// Clear the interrupt flag
	IFS1bits.U2RXIF = 0;
}

/**
 * This is the interrupt handler for UART2 transmission.
 * It is called after at least one byte is transmitted (
 * depends on UTXISEL<1:0> as to specifics). This function
 * therefore keeps adding bytes to transmit if there're more
 * in the queue.
 */
void _ISR _U2TXInterrupt(void)
{
	// Due to a bug with the dsPIC33E, this interrupt can trigger prematurely. We sit and poll the
	// TRMT bit to stall until the character is properly transmit.
	while (!U2STAbits.TRMT);

	Uart2StartTransmission();

	// Clear the interrupt flag
	IFS1bits.U2TXIF = 0;
}
