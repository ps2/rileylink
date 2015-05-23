/* Minimed RF communications */

/* Note: must issue software reset (command = 4) before transferring data
 * to make sure spi is synced */

 #include "minimed_rf.h"

#ifdef __GNUC__
#define XDATA(x)
#else
#define XDATA(x) __xdata __at x
#endif

#ifdef MOCK_RADIO

#include <stdio.h>
unsigned char U1DBUF;
unsigned char CHANNR;
unsigned char P0_0;
unsigned char P1_0;
unsigned char P1_1;
unsigned char EA;
unsigned char WDCTL;
unsigned char RFTXRXIE;
unsigned char MARCSTATE;
unsigned char RFIF;
unsigned char RFD;
unsigned char S1CON;
unsigned char SLEEP;

#endif

unsigned char lastCmd = CMD_NOP;

// SPI Mode
#define SPI_MODE_CMD  0
#define SPI_MODE_ARG  1
#define SPI_MODE_READ 2
unsigned char spiMode = SPI_MODE_CMD;

// Errors
#define ERROR_DATA_BUFFER_OVERFLOW 0x50
#define ERROR_TOO_MANY_PACKETS 0x51
#define ERROR_RF_TX_OVERFLOW 0x52

// Resource usage defines
#define BUFFER_SIZE 1024
#define MAX_PACKETS 100
#define MAX_PACKET_SIZE 250

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))
#define TRUE 1
#define FALSE 0

#define BIT0 0x1
#define BIT1 0x2
#define BIT2 0x4
#define BIT3 0x8
#define BIT4 0x10
#define BIT5 0x20
#define BIT6 0x40
#define BIT7 0x80

// Radio mode
unsigned char radioMode = RADIO_MODE_RX;

// Data buffer
int bufferWritePos = 0;
int bufferReadPos = 0;
unsigned int dataBufferBytesUsed = 0;

unsigned char packetNumber = 0;

// Packet
typedef struct Packet {
  int dataStartIdx;
  unsigned char length;
  unsigned char rssi;
  unsigned char packetNumber;
} Packet;

int packetCount = 0;
int packetHeadIdx = 0;
int packetTailIdx = 0;

// Packet sending counters
int currentPacketByteIdx = 0;
int currentPacketBytesRemaining = 0;
int crcErrorCount = 0;

unsigned char lastError = 0;
unsigned char sendingPacket = FALSE;
unsigned char packetOverflowCount = 0;
unsigned char bufferOverflowCount = 0;

int symbolInputBitCount = 0;
int symbolOutputBuffer = 0;
int symbolOutputBitCount = 0;
int symbolErrorCount = 0;

// Packet transmitting
int radioOutputBufferWritePos = 0;
int radioOutputBufferReadPos = 0;
int radioOutputDataLength = 0;

// 1024 bytes (0xfb00 - 0xff00)
unsigned char XDATA(0xfb00) dataBuffer[BUFFER_SIZE]; // RF Input buffer

// 100 * 5 bytes = 500 bytes
Packet XDATA(0xf7a8) packets[MAX_PACKETS];

// 256 bytes
unsigned char XDATA(0xf6a8) crcTable[256];

// 256 bytes
unsigned char XDATA(0xf5a8) radioOutputBuffer[256];

// Symbol decoding - 53 bytes + 1 pad 
unsigned char XDATA(0xf572) symbolTable[] = {16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 11, 16, 13, 14, 16, 16, 16, 16, 16, 16, 0, 7, 16, 16, 9, 8, 16, 15, 16, 16, 16, 16, 16, 16, 3, 16, 5, 6, 16, 16, 16, 10, 16, 12, 16, 16, 16, 16, 1, 2, 16, 4};

int symbolInputBuffer = 0;
void initMinimedRF() {

  // init crc table
  unsigned char polynomial = 0x9b;
  const unsigned char msbit = 0x80;
  int i, j;
  unsigned char t = 1;

  crcTable[0] = 0;

  // msb
  t = msbit;
  for (i = 1; i < 256; i *= 2) {
    t = (t << 1) ^ (t & msbit ? polynomial : 0);
    for (j = 0; j < i; j++) {
      //printf("i = %d, j = %d, t = %d\n", i, j, t);
      crcTable[i+j] = crcTable[j] ^ t;
    }
  }

  // Initialize first packet
  packets[0].dataStartIdx = 0;
  packets[0].length = 0;

  setChannel(2);
}

unsigned char cmdGetByte() {
  Packet *packet;
  unsigned char rval = 0;
  if (packetCount > 0)
  {
    packet = &packets[packetTailIdx];
    if (!sendingPacket) {
      bufferReadPos = packet->dataStartIdx;
      currentPacketBytesRemaining = packet->length;
      sendingPacket = TRUE;
    }
    if (currentPacketBytesRemaining > 0) {
      rval = dataBuffer[bufferReadPos++];
      currentPacketBytesRemaining--;
      if (currentPacketBytesRemaining == 0) {
        // Done sending packet
        sendingPacket = FALSE;
        packetCount--;
        packetTailIdx++;
        if (packetTailIdx == MAX_PACKETS) {
          packetTailIdx = 0;
        }
      }
      if (bufferReadPos == BUFFER_SIZE) {
        bufferReadPos = 0;
      }
      dataBufferBytesUsed--;
    } else {
      rval = 0x88;
    }
  } else {
    // Request to get packet data, when there are no packets available!
    rval = 0x99;
  }
  return rval;
}

void doCommand(unsigned char cmd) {
  lastCmd = cmd;
  switch (cmd) {
  case CMD_GET_CHANNEL:
    U1DBUF = CHANNR;
    break;
  case CMD_SET_CHANNEL:
  case CMD_SEND_PACKET:
    spiMode = SPI_MODE_ARG;
    break;
  case CMD_GET_LENGTH:
    //P1_1 = packetHeadIdx == packetTailIdx ? 0 : 1;
    //P0_0 = packets[packetTailIdx].length > 0 ? 1 : 0; // low
    //P0_1 = packetCount > 0 ? 1 : 0;                   // high
    if (packetCount > 0) {
      U1DBUF = packets[packetTailIdx].length;
    } else {
      U1DBUF = 0;
    }
    break;
  case CMD_GET_RSSI:
    U1DBUF = packets[packetTailIdx].rssi;
    break;
  case CMD_GET_PACKET_NUMBER:
    U1DBUF = packets[packetTailIdx].packetNumber;
    break;
  case CMD_GET_BYTE:
    U1DBUF = cmdGetByte();
    break;
  case CMD_RESET:
    P1_1 = 1; // Red
    EA = 0;
    WDCTL = BIT3 | BIT0;
    break;
  case CMD_GET_ERROR:
    U1DBUF = lastError;
    lastError = 0;
    break;
  case CMD_GET_RADIO_MODE:
    U1DBUF = radioMode;
    break;
  case CMD_GET_PACKET_COUNT:
    U1DBUF = packetCount; 
    break;
  case CMD_GET_PACKET_HEAD_IDX:
    U1DBUF = packetHeadIdx;
    break;
  case CMD_GET_PACKET_TAIL_IDX:
    U1DBUF = packetTailIdx;
    break;
  case CMD_GET_PACKET_OVERFLOW_COUNT:
    U1DBUF = packetOverflowCount;
    break;
  case CMD_GET_BUFFER_OVERFLOW_COUNT:
    U1DBUF = bufferOverflowCount;
    break;

  default:
    U1DBUF = 0x22;
    break;
  }
}

void setChannel(unsigned char newChannel) {
  // Guard against using remote channel
  if (newChannel != 4) {
    CHANNR = newChannel;
    RFTXRXIE = 0;
  }
}


void handleRX1() {
  unsigned char value;
  if (spiMode == SPI_MODE_CMD) {
    doCommand(U1DBUF);
  } else if (spiMode == SPI_MODE_ARG) {
    value = U1DBUF;
    switch (lastCmd) {
    case CMD_SET_CHANNEL:
      setChannel(value);
      break;
    case CMD_SEND_PACKET:
      radioOutputDataLength = value;
      spiMode = SPI_MODE_READ;
      break;
    }
    spiMode = SPI_MODE_CMD;
  } else if (spiMode == SPI_MODE_READ) {
    radioOutputBuffer[radioOutputBufferWritePos++] = U1DBUF;
    if (radioOutputBufferWritePos == radioOutputDataLength) {
      radioOutputBufferReadPos = 0;
      // Set radio mode to tx;
      radioMode = RADIO_MODE_TX;
      RFTXRXIE = 0;
    }
  }
}

void dropCurrentPacket() {
  bufferWritePos = packets[packetHeadIdx].dataStartIdx;
  dataBufferBytesUsed -= packets[packetHeadIdx].length;
  packets[packetHeadIdx].length = 0;
  // Disable RFTXRX interrupt, which signals main loop to restart radio.
  RFTXRXIE = 0;
}

void addDecodedByte(unsigned char value) {
  if (dataBufferBytesUsed < BUFFER_SIZE) {
    dataBuffer[bufferWritePos] = value;
    bufferWritePos++;
    dataBufferBytesUsed++;
    packets[packetHeadIdx].length++;
    if (bufferWritePos == BUFFER_SIZE) {
      bufferWritePos = 0;
    }
    if (packets[packetHeadIdx].length >= MAX_PACKET_SIZE) {
      dropCurrentPacket();
    }
  } else {
    bufferOverflowCount++;
    dropCurrentPacket();
  }
}

void finishIncomingPacket() {
  // Compute crc
  
  unsigned int packetCrc;
  unsigned char crc = 0;

  int crcReadIdx = packets[packetHeadIdx].dataStartIdx;
  int crcLen = packets[packetHeadIdx].length-1;

  /* Assign rssi */
  packets[packetHeadIdx].rssi = RSSI;

  /* Assign packet number */
  packets[packetHeadIdx].packetNumber = packetNumber;
  packetNumber++;

  /* loop over the buffer data */
  while (crcLen-- > 0) {
    crc = crcTable[(crc ^ dataBuffer[crcReadIdx]) & 0xff];
    crcReadIdx++;
    if (crcReadIdx >= BUFFER_SIZE) {
      crcReadIdx = 0;
    }
  }
  packetCrc = dataBuffer[crcReadIdx];

  if (packetCount+1 == MAX_PACKETS) {
    // Packet count overflow
    lastError = ERROR_TOO_MANY_PACKETS;
    // Reuse this packet's space.
    packetOverflowCount++;
    dropCurrentPacket();
//  } else if (packetCrc != crc) {
//    //printf("invalid crc\n");
//    crcErrorCount++;
//    // Drop this packet
//    dropCurrentPacket();
  } else {
    P0_1 = !P0_1;
    //printf("valid crc\n");
    if (packets[packetHeadIdx].length == 0) {
    }
    packetCount++;
    packetHeadIdx++;
    if (packetHeadIdx == MAX_PACKETS) {
      packetHeadIdx = 0;
    }
    packets[packetHeadIdx].dataStartIdx = bufferWritePos;
    packets[packetHeadIdx].length = 0;
  }

  // Reset symbol processing state
  symbolInputBuffer = 0;
  symbolInputBitCount = 0;
  symbolOutputBuffer = 0;
  symbolOutputBitCount = 0;
  symbolErrorCount = 0;

  // Disable RFTXRX interrupt, which signals main loop to restart radio.
  RFTXRXIE = 0;
}

void receiveRadioSymbol(unsigned char value) {

  unsigned char symbol;
  unsigned char outputSymbol;
  //printf("receiveRadioSymbol %d\n", value);

  if (value == 0) {
    if (packets[packetHeadIdx].length > 0) {
      finishIncomingPacket();
    }
    return;
  }

  symbolInputBuffer = (symbolInputBuffer << 8) + value;
  symbolInputBitCount += 8;
  while (symbolInputBitCount >= 6) {
    symbol = (symbolInputBuffer >> (symbolInputBitCount-6)) & 0b111111;
    symbolInputBitCount -= 6;
    if (symbol == 0) {
      continue;
    }
    if (symbol >= sizeof(symbolTable) ||
        (symbol = symbolTable[symbol]) == 16) {
      symbolErrorCount++;
      break;
    } else {
      symbolOutputBuffer = (symbolOutputBuffer << 4) + symbol;
    }
    symbolOutputBitCount += 4;
  }
  while (symbolOutputBitCount >= 8) {
    outputSymbol = (symbolOutputBuffer >> (symbolOutputBitCount-8)) & 0b11111111;
    symbolOutputBitCount-=8;
    addDecodedByte(outputSymbol);
  }
  if (symbolErrorCount > 0 && packets[packetHeadIdx].length > 0) {
    finishIncomingPacket();
  }
}

void handleRFTXRX() {
  switch (MARCSTATE) {
  case MARC_STATE_RX:
    receiveRadioSymbol(RFD);
    break;
  case MARC_STATE_TX:
    RFD = radioOutputBuffer[radioOutputBufferReadPos++];
    if (radioOutputBufferReadPos == radioOutputDataLength) {
      radioOutputBufferWritePos = 0;
      radioOutputBufferReadPos = 0;
      radioOutputDataLength = 0;
      radioMode = RADIO_MODE_IDLE;
      RFTXRXIE = 0;
    }
    break;
  }
}

void handleRF()
{
  S1CON &= ~0x03; // Clear CPU interrupt flag
  if(RFIF & 0x80) // TX underflow
  {
    //irq_txunf(); // Handle TX underflow
    RFIF &= ~0x80; // Clear module interrupt flag
  }
  else if(RFIF & 0x40) // RX overflow
  {
    //irq_rxovf(); // Handle RX overflow
    RFIF &= ~0x40; // Clear module interrupt flag
  }
  else if(RFIF & 0x20) // RX timeout
  {
    RFIF &= ~0x20; // Clear module interrupt flag
  }
  // Use ”else if” to check and handle other RFIF flags
}
