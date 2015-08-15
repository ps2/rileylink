#ifndef MINIMED_RF_H
#define MINIMED_RF_H

void initMinimedRF();
void handleRX0();
void handleRX1();
void handleRFTXRX();
void handleRF();
void handleTimer();
void setRXChannel(unsigned char newChannel);

void enterRX();
void enterTX();

// Commands
#define CMD_NOP 0
#define CMD_GET_CHANNEL 1
#define CMD_SET_CHANNEL 2
#define CMD_GET_LENGTH 3
#define CMD_GET_BYTE 4
#define CMD_RESET 5
#define CMD_GET_ERROR 6
#define CMD_GET_PACKET_NUMBER 7
#define CMD_SEND_PACKET 9
#define CMD_GET_RADIO_MODE 10
#define CMD_GET_PACKET_COUNT 11
#define CMD_GET_PACKET_HEAD_IDX 12
#define CMD_GET_PACKET_TAIL_IDX 13
#define CMD_GET_PACKET_OVERFLOW_COUNT 14
#define CMD_GET_BUFFER_OVERFLOW_COUNT 15
#define CMD_GET_RSSI 16
#define CMD_SET_TX_CHANNEL 17

// Radio Mode
#define RADIO_MODE_IDLE 0
#define RADIO_MODE_RX   1
#define RADIO_MODE_TX   2
extern unsigned char radioMode;

// RileyLink HW
#define GREEN_LED P0_0
#define BLUE_LED P0_1

#ifdef MOCK_RADIO

extern unsigned char U0DBUF;
extern unsigned char CHANNR;
extern unsigned char P0_0;
extern unsigned char P1_0;
extern unsigned char P1_1;
extern unsigned char EA;
extern unsigned char WDCTL;
extern unsigned char RFTXRXIE;
extern unsigned char MARCSTATE;
extern unsigned char RFIF;
extern unsigned char RFD;
extern unsigned char S1CON;
extern unsigned char SLEEP;

#define MARC_STATE_RX 1
#define MARC_STATE_TX 2
#define SLEEP_OSC_PD 2
#define SLEEP_XOSC_S 3
#define CLKCON_OSC 4

#else

#include <cc1110.h>  // /usr/share/sdcc/include/mcs51/cc1110.h
#include "ioCCxx10_bitdef.h"

#endif


#endif
