//
//  CBPeripheral+UUIDString.h
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (UUIDString)

@property (nonatomic, readonly) NSString *UUIDString;

@end
