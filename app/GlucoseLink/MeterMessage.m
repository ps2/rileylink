//
//  MeterMessage.m
//  GlucoseLink
//
//  Created by Pete Schwamb on 5/30/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "MeterMessage.h"

@implementation MeterMessage

- (instancetype)initWithData:(NSData*)data
{
  self = [super init];
  if (self) {
    self.data = [data subdataWithRange:NSMakeRange(4, data.length-5)];
  }
  return self;
}

- (NSDictionary*) bitBlocks {
  return @{@"alert": @[@5, @2],
           @"glucose": @[@7, @9]
           };
}

- (NSInteger) glucose {
  return [self b:@"glucose"];
}

@end
