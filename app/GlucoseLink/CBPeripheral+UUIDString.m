//
//  CBPeripheral+UUIDString.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "CBPeripheral+UUIDString.h"

@implementation CBPeripheral (UUIDString)

- (NSString *) UUIDString {
  return self.identifier.UUIDString;
}

@end
