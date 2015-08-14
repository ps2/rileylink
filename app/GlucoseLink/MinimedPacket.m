//
//  MinimedPacket.m
//  GlucoseLink
//
//  Created by Pete Schwamb on 8/5/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import "MinimedPacket.h"
#import "NSData+Conversion.h"

static const unsigned char crcTable[256] = { 0x0, 0x9B, 0xAD, 0x36, 0xC1, 0x5A, 0x6C, 0xF7, 0x19, 0x82, 0xB4, 0x2F, 0xD8, 0x43, 0x75, 0xEE, 0x32, 0xA9, 0x9F, 0x4, 0xF3, 0x68, 0x5E, 0xC5, 0x2B, 0xB0, 0x86, 0x1D, 0xEA, 0x71, 0x47, 0xDC, 0x64, 0xFF, 0xC9, 0x52, 0xA5, 0x3E, 0x8, 0x93, 0x7D, 0xE6, 0xD0, 0x4B, 0xBC, 0x27, 0x11, 0x8A, 0x56, 0xCD, 0xFB, 0x60, 0x97, 0xC, 0x3A, 0xA1, 0x4F, 0xD4, 0xE2, 0x79, 0x8E, 0x15, 0x23, 0xB8, 0xC8, 0x53, 0x65, 0xFE, 0x9, 0x92, 0xA4, 0x3F, 0xD1, 0x4A, 0x7C, 0xE7, 0x10, 0x8B, 0xBD, 0x26, 0xFA, 0x61, 0x57, 0xCC, 0x3B, 0xA0, 0x96, 0xD, 0xE3, 0x78, 0x4E, 0xD5, 0x22, 0xB9, 0x8F, 0x14, 0xAC, 0x37, 0x1, 0x9A, 0x6D, 0xF6, 0xC0, 0x5B, 0xB5, 0x2E, 0x18, 0x83, 0x74, 0xEF, 0xD9, 0x42, 0x9E, 0x5, 0x33, 0xA8, 0x5F, 0xC4, 0xF2, 0x69, 0x87, 0x1C, 0x2A, 0xB1, 0x46, 0xDD, 0xEB, 0x70, 0xB, 0x90, 0xA6, 0x3D, 0xCA, 0x51, 0x67, 0xFC, 0x12, 0x89, 0xBF, 0x24, 0xD3, 0x48, 0x7E, 0xE5, 0x39, 0xA2, 0x94, 0xF, 0xF8, 0x63, 0x55, 0xCE, 0x20, 0xBB, 0x8D, 0x16, 0xE1, 0x7A, 0x4C, 0xD7, 0x6F, 0xF4, 0xC2, 0x59, 0xAE, 0x35, 0x3, 0x98, 0x76, 0xED, 0xDB, 0x40, 0xB7, 0x2C, 0x1A, 0x81, 0x5D, 0xC6, 0xF0, 0x6B, 0x9C, 0x7, 0x31, 0xAA, 0x44, 0xDF, 0xE9, 0x72, 0x85, 0x1E, 0x28, 0xB3, 0xC3, 0x58, 0x6E, 0xF5, 0x2, 0x99, 0xAF, 0x34, 0xDA, 0x41, 0x77, 0xEC, 0x1B, 0x80, 0xB6, 0x2D, 0xF1, 0x6A, 0x5C, 0xC7, 0x30, 0xAB, 0x9D, 0x6, 0xE8, 0x73, 0x45, 0xDE, 0x29, 0xB2, 0x84, 0x1F, 0xA7, 0x3C, 0xA, 0x91, 0x66, 0xFD, 0xCB, 0x50, 0xBE, 0x25, 0x13, 0x88, 0x7F, 0xE4, 0xD2, 0x49, 0x95, 0xE, 0x38, 0xA3, 0x54, 0xCF, 0xF9, 0x62, 0x8C, 0x17, 0x21, 0xBA, 0x4D, 0xD6, 0xE0, 0x7B };



@interface MinimedPacket ()

@property (nonatomic, assign) NSInteger codingErrorCount;

@end

@implementation MinimedPacket

+ (void)initialize {
}

- (instancetype)initWithData:(NSData*)data
{
  self = [super init];
  if (self) {
    _codingErrorCount = 0;
    if (data.length > 0) {
      unsigned char rssiDec = ((const unsigned char*)[data bytes])[0];
      unsigned char rssiOffset = 73;
      if (rssiDec >= 128) {
        self.rssi = (short)((short)( rssiDec - 256) / 2) - rssiOffset;
      } else {
        self.rssi = (rssiDec / 2) - rssiOffset;
      }
    }
    if (data.length > 1) {
      self.packetNumber = ((const unsigned char*)[data bytes])[1];
    }

    if (data.length > 2) {
      //_data = [self decodeRFEncoding:data]; // cc1110 is doing decoding now
      _data = [data subdataWithRange:NSMakeRange(2, data.length - 2)];
      //NSLog(@"New packet: %@", [data hexadecimalString]);
    }
  }
  return self;
}

+ (unsigned char) crcForData:(NSData*)data {
  unsigned char crc = 0;
  const unsigned char *pdata = data.bytes;
  unsigned long nbytes = data.length;
  /* loop over the buffer data */
  while (nbytes-- > 0) {
    crc = crcTable[(crc ^ *pdata++) & 0xff];
  }
  return crc;
}

- (BOOL) crcValid {
  unsigned char crc = 0;
  const unsigned char *pdata = _data.bytes;
  unsigned long nbytes = _data.length-1;
  const unsigned char packetCrc = pdata[nbytes];
  /* loop over the buffer data */
  while (nbytes-- > 0) {
    crc = crcTable[(crc ^ *pdata++) & 0xff];
  }
  //printf("crc = 0x%x, last_byte=0x%x\n", crc, packetCrc);
  return crc == packetCrc;
}

- (BOOL) isValid {
  return _data.length > 0 && [self crcValid];
}

+ (NSData*)encodeData:(NSData*)data {
  NSMutableData *outData = [NSMutableData data];
  NSMutableData *dataPlusCrc = [data mutableCopy];
  unsigned char crc = [MinimedPacket crcForData:data];
  [dataPlusCrc appendBytes:&crc length:1];
  char codes[16] = {21,49,50,35,52,37,38,22,26,25,42,11,44,13,14,28};
  const unsigned char *inBytes = [dataPlusCrc bytes];
  unsigned int acc = 0x0;
  int bitcount = 0;
  for (int i=0; i < dataPlusCrc.length; i++) {
    acc <<= 6;
    acc |= codes[inBytes[i] >> 4];
    bitcount += 6;
    
    acc <<= 6;
    acc |= codes[inBytes[i] & 0x0f];
    bitcount += 6;
    
    while (bitcount >= 8) {
      unsigned char outByte = acc >> (bitcount-8) & 0xff;
      [outData appendBytes:&outByte length:1];
      bitcount -= 8;
      acc &= (0xffff >> (16-bitcount));
    }
  }
  if (bitcount > 0) {
    acc <<= (8-bitcount);
    unsigned char outByte = acc & 0xff;
    [outData appendBytes:&outByte length:1];
  }
  return outData;
}

- (NSData*)decodeRF:(NSData*) rawData {
  // Converted from ruby using: CODE_SYMBOLS.each{|k,v| puts "@#{Integer("0b"+k)}: @#{Integer("0x"+v)},"};nil
  NSDictionary *codes = @{@21: @0,
                          @49: @1,
                          @50: @2,
                          @35: @3,
                          @52: @4,
                          @37: @5,
                          @38: @6,
                          @22: @7,
                          @26: @8,
                          @25: @9,
                          @42: @10,
                          @11: @11,
                          @44: @12,
                          @13: @13,
                          @14: @14,
                          @28: @15};
  NSMutableData *output = [NSMutableData data];
  const unsigned char *bytes = [rawData bytes];
  int availBits = 0;
  unsigned int x = 0;
  for (int i = 0; i < [rawData length]; i++)
  {
    x = (x << 8) + bytes[i];
    availBits += 8;
    if (availBits >= 12) {
      NSNumber *hiNibble = codes[[NSNumber numberWithInt:(x >> (availBits - 6))]];
      NSNumber *loNibble = codes[[NSNumber numberWithInt:(x >> (availBits - 12)) & 0b111111]];
      if (hiNibble && loNibble) {
        unsigned char decoded = ([hiNibble integerValue] << 4) + [loNibble integerValue];
        [output appendBytes:&decoded length:1];
      } else {
        _codingErrorCount += 1;
      }
      availBits -= 12;
      x = x & (0xffff >> (16-availBits));
    }
  }
  return output;
}

- (NSString*) hexadecimalString {
  return [_data hexadecimalString];
}

- (unsigned char)byteAt:(NSInteger)index {
  if (_data && index < [_data length]) {
    return ((unsigned char*)[_data bytes])[index];
  } else {
    return 0;
  }
}

- (PacketType) packetType {
  return [self byteAt:0];
}

- (MessageType) messageType {
  return [self byteAt:4];
}

- (NSString*) address {
  return [NSString stringWithFormat:@"%02x%02x%02x", [self byteAt:1], [self byteAt:2], [self byteAt:3]];
}

@end
