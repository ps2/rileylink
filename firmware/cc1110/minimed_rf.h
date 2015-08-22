#pragma once
#include <stdint.h>

void initMinimedRF();
void handleRX0();
void handleRX1();
void handleRFTXRX();
void handleRF();
void handleTimer();
void setRXChannel(uint8_t newChannel);

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
extern uint8_t radioMode;

// RileyLink HW
#define GREEN_LED P0_0
#define BLUE_LED P0_1

#ifdef MOCK_RADIO

extern uint8_t U0DBUF;
extern uint8_t CHANNR;
extern uint8_t P0_0;
extern uint8_t P1_0;
extern uint8_t P1_1;
extern uint8_t EA;
extern uint8_t WDCTL;
extern uint8_t RFTXRXIE;
extern uint8_t MARCSTATE;
extern uint8_t RFIF;
extern uint8_t RFD;
extern uint8_t S1CON;
extern uint8_t SLEEP;

#define MARC_STATE_RX 1
#define MARC_STATE_TX 2
#define SLEEP_OSC_PD 2
#define SLEEP_XOSC_S 3
#define CLKCON_OSC 4

#else

#include <cc1110.h>  // /usr/share/sdcc/include/mcs51/cc1110.h
#include "ioCCxx10_bitdef.h"

#endif


