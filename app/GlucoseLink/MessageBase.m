//
//  MessageBase.m
//  GlucoseLink
//
//  Created by Pete Schwamb on 5/26/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "MessageBase.h"

@implementation MessageBase


- (instancetype)initWithData:(NSData*)data
{
  self = [super init];
  if (self) {
    _data = data;
  }
  return self;
}

- (NSDictionary*) bitBlocks {
  return @{};
}

- (unsigned char) getBitAtIndex:(NSInteger)idx {
  NSInteger byteOffset = idx/8;
  int posBit = idx%8;
  if (byteOffset < _data.length) {
    unsigned char valByte = ((unsigned char*)_data.bytes)[byteOffset];
    return valByte>>(8-(posBit+1)) & 0x1;
  } else {
    return 0;
  }
}

- (NSInteger) b:(NSString*)key {
  NSArray *range = [self bitBlocks][key];
  NSInteger bitsNeeded = [[range lastObject] integerValue];
  NSInteger offset = [[range firstObject] integerValue];
  NSInteger rval = 0;
  while (bitsNeeded > 0) {
    rval = (rval << 1) + [self getBitAtIndex:offset++];
    bitsNeeded--;
  }
  return rval;
}



@end
