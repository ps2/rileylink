#include <stdio.h>

// Resource usage defines
#define BUFFER_SIZE 1024
#define MAX_PACKETS 100
#define MAX_PACKET_SIZE 255

// Data buffer
unsigned char dataBuffer[BUFFER_SIZE]; // RF Input buffer
int bufferWritePos = 0;
int bufferReadPos = 0;
unsigned int dataBufferBytesUsed = 0;

// Packet
typedef struct Packet {
  int dataStartIdx;
  unsigned char length;
  unsigned char rssi;
} Packet;

Packet packets[MAX_PACKETS];
int packetCount = 0;
int packetHeadIdx = 0;
int packetTailIdx = 0;

// Packet sending counters
int currentPacketByteIdx = 0;
int currentPacketBytesRemaining = 0;

unsigned char lastError = 0;

// Symbol decoding
unsigned char symbolTable[] = {16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 11, 16, 13, 14, 16, 16, 16, 16, 16, 16, 0, 7, 16, 16, 9, 8, 16, 15, 16, 16, 16, 16, 16, 16, 3, 16, 5, 6, 16, 16, 16, 10, 16, 12, 16, 16, 16, 16, 1, 2, 16, 4};

int symbolInputBuffer = 0;
int symbolInputBitCount = 0;
int symbolOutputBuffer = 0;
int symbolOutputBitCount = 0;
int symbolErrorCount = 0;

void addDecodedByte(unsigned char value) {
  if (dataBufferBytesUsed < BUFFER_SIZE) {
    dataBuffer[bufferWritePos] = value;
    bufferWritePos++;
    dataBufferBytesUsed++;
    packets[packetHeadIdx].length++;
    if (bufferWritePos == BUFFER_SIZE) {
      bufferWritePos = 0;
    }
  } 
}

void receiveRadioSymbol(unsigned char value) {

  unsigned char symbol;
  unsigned char outputSymbol;

  symbolInputBuffer = (symbolInputBuffer << 8) + value;
  symbolInputBitCount += 8;
  while (symbolInputBitCount >= 6) {
    symbol = (symbolInputBuffer >> (symbolInputBitCount-6)) & 0b111111;
    symbolInputBitCount -= 6;
    if (symbol >= sizeof(symbolTable) ||
        (symbol = symbolTable[symbol]) == 16) {
      // Symbol error: add 4 zero bits
      printf("symbol error: 0x%x\n", value);
      symbolOutputBuffer = (symbolOutputBuffer << 4);
      symbolErrorCount++;
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
}



void testDecode() {
  int i;
  receiveRadioSymbol(0xA9);
  receiveRadioSymbol(0x69);
  receiveRadioSymbol(0xB2);
  receiveRadioSymbol(0x69);
  receiveRadioSymbol(0x55);
  receiveRadioSymbol(0x96);
  receiveRadioSymbol(0x94);
  receiveRadioSymbol(0xD5);
  receiveRadioSymbol(0x55);
  receiveRadioSymbol(0x2D);
  receiveRadioSymbol(0x65);
  receiveRadioSymbol(0x80);
  receiveRadioSymbol(0x00);
  printf("Decoded: 0x");
  for (i=0; i<bufferWritePos; i++) {
    printf("%02x", dataBuffer[i]);
  }
  printf("\n");
}


int main(int argc, char **argv) {
  printf("Running tests...\n");
  testDecode();
  //testEncode();
  return 0;
}

