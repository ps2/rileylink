//
//  RileyLinkBLE.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "RileyLinkBLEDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>


@implementation RileyLinkBLEDevice

- (BOOL) isConnected {
  return self.myPeripheral.state == CBPeripheralStateConnected;
}

- (CBPeripheral *) myPeripheral {
  return (CBPeripheral *) _peripheral;
}


@end
