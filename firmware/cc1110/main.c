/* Interface for minimed RF communications exposed as an SPI slave. */

#include <cc1110.h>  // /usr/share/sdcc/include/mcs51/cc1110.h
#include "ioCCxx10_bitdef.h"
#include "minimed_rf.h"

// These values will give a baud rate of approx. 62.5kbps for 26 MHz clock
#define SPI_BAUD_M 59
#define SPI_BAUD_E 11

#define BIT0 0x1
#define BIT1 0x2
#define BIT2 0x4
#define BIT3 0x8
#define BIT4 0x10
#define BIT5 0x20
#define BIT6 0x40
#define BIT7 0x80

void configureSPI(void)
{
    /***************************************************************************
     * Setup I/O ports
     *
     * Port and pins used by USART1 operating in SPI-mode are
     * (SS): P1_4
     *  (C): P1_5
     * (MO): P1_6
     * (MI): P1_7
     *
     * These pins can be set to function as peripheral I/O to be be used by
     * USART1 SPI. Note however, when SPI is in master mode, only MOSI, MISO,
     * and SCK should be configured as peripheral I/O's. If the external
     * slave device requires a slave select signal (SSN), then the master
     * can control the external SSN by using one of its GPIO pin as output.
     */

    // configure USART1 for Alternative 2 => Port P1 (PERCFG.U1CFG = 1)
    // To avoid potential I/O conflict with USART0:
    // Configure USART0 for Alternative 1 => Port P0 (PERCFG.U0CFG = 0)
    PERCFG = (PERCFG & ~PERCFG_U0CFG) | PERCFG_U1CFG;

    // Give priority to USART 1 over USART 0 for port 0 pins
    P2DIR = 0x01;

    // Set pins 2, 3 and 5 as peripheral I/O and pin 4 as GPIO output
    P1SEL = P1SEL | BIT4 | BIT5 | BIT6 | BIT7;
    P1DIR = P1DIR & ~(BIT4 | BIT5 | BIT6 | BIT7);

    /***************************************************************************
     * Configure SPI
     */

    // Set USART to SPI mode and Slave mode
    U1CSR = (U1CSR & ~U1CSR_MODE) | U1CSR_SLAVE;

    // Set:
    // - mantissa value
    // - exponent value
    // - clock phase to be centered on first edge of SCK period
    // - negative clock polarity (SCK low when idle)
    // - bit order for transfers to LSB first
    U1BAUD = SPI_BAUD_M;
    U1GCR = (U1GCR & ~(U1GCR_BAUD_E | U1GCR_CPOL | U1GCR_CPHA | U1GCR_ORDER))
        | SPI_BAUD_E;

}

void configureRadio() 
{
  /* RF settings SoC: CC1110 */
  SYNC1     = 0xFF; // sync word, high byte
  SYNC0     = 0x00; // sync word, low byte
  PKTLEN    = 0xFE; // packet length
  PKTCTRL0  = 0x00; // packet automation control
  CHANNR    = 0x02; // channel number
  FSCTRL1   = 0x06; // frequency synthesizer control
  FREQ2     = 0x23; // frequency control word, high byte
  FREQ1     = 0x40; // frequency control word, middle byte
  FREQ0     = 0x00; // frequency control word, low byte
  MDMCFG4   = 0x69; // modem configuration
  MDMCFG3   = 0x4A; // modem configuration
  MDMCFG2   = 0x33; // modem configuration
  MDMCFG1   = 0x11; // modem configuration
  MDMCFG0   = 0xC5; // modem configuration
  DEVIATN   = 0x15; // modem deviation setting
  MCSM0     = 0x18; // main radio control state machine configuration
  FOCCFG    = 0x17; // frequency offset compensation configuration
  FREND0    = 0x11; // front end tx configuration
  FSCAL3    = 0xE9; // frequency synthesizer calibration
  FSCAL2    = 0x2A; // frequency synthesizer calibration
  FSCAL1    = 0x00; // frequency synthesizer calibration
  FSCAL0    = 0x1F; // frequency synthesizer calibration
  TEST1     = 0x31; // various test settings
  TEST0     = 0x09; // various test settings
  //PA_TABLE1 = 0x8E; // pa power setting 1
}

void urx1_isr(void) __interrupt URX1_VECTOR
{
  handleRX1();
}

void rftxrx_isr(void) __interrupt RFTXRX_VECTOR
{
  P0_1 = 1;
  handleRFTXRX();
}

void rf_interrupt(void) __interrupt RF_VECTOR
{
  handleRF();
}

int main(void)
{
  // init LEDS
  P0DIR |= 0x03;
  P0_0 = 1; // Red
  P0_1 = 0; // Blue

  // Set the system clock source to HS XOSC and max CPU speed,
  // ref. [clk]=>[clk_xosc.c]
  SLEEP &= ~SLEEP_OSC_PD;
  while( !(SLEEP & SLEEP_XOSC_S) );
  CLKCON = (CLKCON & ~(CLKCON_CLKSPD | CLKCON_OSC)) | CLKSPD_DIV_1;
  while (CLKCON & CLKCON_OSC);
  SLEEP |= SLEEP_OSC_PD;

  configureSPI();
  configureRadio();

  initMinimedRF();

  TCON &= ~BIT3; // Clear URX1IFj
  URX1IE = 1;    // Enable URX1IE interrupt

  // Global interrupt enable
  EA = 1;

  while (1) {
    // Reset radio
    RFST = RFST_SIDLE;
    while((MARCSTATE & MARCSTATE_MARC_STATE) != MARC_STATE_IDLE);

    if (radioMode == RADIO_MODE_TX) {
      /* Put radio into TX. */
      RFST = RFST_STX;
      while ((MARCSTATE & MARCSTATE_MARC_STATE) != MARC_STATE_TX);
    } else if (radioMode == RADIO_MODE_RX) {
      /* Put radio into RX. */
      //P0_0 = !P0_0;
      RFST = RFST_SRX;
      while ((MARCSTATE & MARCSTATE_MARC_STATE) != MARC_STATE_RX);
    }

    /* Radio is now in RX or TX */
    /* Enable rx/tx interrupt */
    TCON &= ~(0x02);  // Clear RFTXRXIE
    RFTXRXIE = 1;
    while (RFTXRXIE && MARCSTATE == MARC_STATE_RX);
    RFTXRXIE = 0;
  }
}
