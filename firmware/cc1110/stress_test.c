#include <stdio.h>
#include <stdlib.h>
#include "minimed_rf.h"

unsigned char xferSPI(unsigned char val)
{
  U0DBUF = val;
  handleRX0(0);
  return U0DBUF;
}

void mockRadioData(char *hexData, int length) {
  unsigned char val;
  char *pos = hexData;
  for(int count = 0; count < length/2; count++) {
    sscanf(pos, "%2hhx", &val);
    printf("RFRX 0x%02x\n", val);
    RFD = val;
    handleRFTXRX();
    pos += 2 * sizeof(char);
  }
}

void readSPIPacket() {
  unsigned char size = xferSPI(CMD_GET_LENGTH);
  printf("Size = %d\n", size);
  while (size > 0) {
    unsigned char val = xferSPI(CMD_GET_BYTE);
    printf("data = 0x%02x\n", val);
    size--;
  }
}

int main(int argc, char **argv)
{
  initMinimedRF();

  while (1) {
    MARCSTATE = MARC_STATE_RX;
    mockRadioData("ab2959595965574ab2d31c565748ea54e55a54b5558cd8cd55557194b56357156535ac5659956a55c55555556355555568bc5657255554e55a54b5555555b100", 128);
    mockRadioData("ab2959595965574ab2d31c565748ea54e55a54b5558cd8cd55557194b56357156535ac5659956a55c55555556355555568bc5657255554e55a54b5555555b100", 128);
    readSPIPacket();
  }
}
