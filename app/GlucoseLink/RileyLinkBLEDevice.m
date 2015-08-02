//
//  RileyLinkBLE.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "RileyLinkBLEDevice.h"
#import "RileyLinkBLEManager.h"
#import "NSData+Conversion.h"

@interface RileyLinkBLEDevice () <CBPeripheralDelegate> {
  CBCharacteristic *packetRxCharacteristic;
  CBCharacteristic *packetTxCharacteristic;
  CBCharacteristic *txTriggerCharacteristic;
  CBCharacteristic *packetRssiCharacteristic;
  CBCharacteristic *batteryCharacteristic;
  CBCharacteristic *packetCountCharacteristic;
  CBCharacteristic *channelCharacteristic;
  NSMutableArray *incomingPackets;
  NSMutableArray *outgoingPackets;
}

@end


@implementation RileyLinkBLEDevice

- (instancetype)init
{
  self = [super init];
  if (self) {
    incomingPackets = [NSMutableArray array];
    outgoingPackets = [NSMutableArray array];
  }
  return self;
}

- (NSArray*) packets {
  return incomingPackets;
}

- (void) sendPacketData:(NSData*)data {
  [self.myPeripheral writeValue:data forCharacteristic:packetTxCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  if (error) {
    NSLog(@"Could not write characteristic: %@", error);
    return;
  }
  NSData *trigger = [NSData dataWithHexadecimalString:@"01"];
  [self.myPeripheral writeValue:trigger forCharacteristic:packetTxCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (BOOL) isConnected {
  return self.myPeripheral.state == CBPeripheralStateConnected;
}

- (void) setPeripheral:(id)peripheral {
  _peripheral = peripheral;
  self.myPeripheral.delegate = self;
}

- (CBPeripheral *) myPeripheral {
  return (CBPeripheral *) _peripheral;
}


- (void) connect {
  [[RileyLinkBLEManager sharedManager] connectToRileyLink:self];
}
   
- (void)updateBatteryLevel {
  [self.myPeripheral readValueForCharacteristic:batteryCharacteristic];
  [self.myPeripheral readRSSI];
}

- (void)didConnect {
  
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  if (error) {
    NSLog(@"Failure while discovering services: %@", error);
    return;
  }
  NSLog(@"didDiscoverServices: %@, %@", peripheral, peripheral.services);
  for (CBService *service in peripheral.services) {
    if ([service.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_BATTERY_SERVICE]]) {
      [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:GLUCOSELINK_BATTERY_UUID]] forService:service];
    } else if ([service.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID]]) {
      [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:GLUCOSELINK_RX_PACKET_UUID],
                                            [CBUUID UUIDWithString:GLUCOSELINK_CHANNEL_UUID],
                                            [CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]] forService:service];
    }
  }
  // Discover other characteristics
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
  //[self sendNotice:RILEY_LINK_EVENT_LIST_UPDATED];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
  if (error) {
    [self cleanup];
    return;
  }
  
  for (CBCharacteristic *characteristic in service.characteristics) {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]]) {
      NSLog(@"***: %@, %@", service.UUID, characteristic.UUID);
      [peripheral setNotifyValue:YES forCharacteristic:characteristic];
      packetCountCharacteristic = characteristic;
      [peripheral readValueForCharacteristic:characteristic];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_CHANNEL_UUID]]) {
      channelCharacteristic = characteristic;
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_RX_PACKET_UUID]]) {
      packetRxCharacteristic = characteristic;
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_TX_PACKET_UUID]]) {
      packetTxCharacteristic = characteristic;
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_TX_TRIGGER_UUID]]) {
      txTriggerCharacteristic = characteristic;
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_BATTERY_UUID]]) {
      batteryCharacteristic = characteristic;
    }
  }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  if (error) {
    NSLog(@"Error writing %@: %@", characteristic, error);
    return;
  }
  NSLog(@"Did write value for characteristic: %@", characteristic.UUID);
  
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  if (error) {
    NSLog(@"Error updating %@: %@", characteristic, error);
    return;
  }
  NSLog(@"didUpdateValueForCharacteristic: %@", characteristic);
  
  if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_RX_PACKET_UUID]]) {
    MinimedPacket *packet = [[MinimedPacket alloc] initWithData:characteristic.value];
    packet.capturedAt = [NSDate date];
    //if ([packet isValid]) {
    [incomingPackets addObject:packet];
    NSDictionary *attrs = @{
                            @"packet": packet,
                            @"peripheral": self.peripheral,
                            @"device": self
                            };
    [[NSNotificationCenter defaultCenter] postNotificationName:RILEY_LINK_EVENT_PACKET_RECEIVED object:attrs];

    [peripheral readValueForCharacteristic:packetCountCharacteristic];
    
  } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_BATTERY_UUID]]) {
    //batteryPct = ((const unsigned char*)[characteristic.value bytes])[0];
    //NSLog(@"Updated battery pct: %d", batteryPct);
  } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]]) {
    const unsigned char packetCount = ((const unsigned char*)[characteristic.value bytes])[0];
    NSLog(@"Updated packet count: %d", packetCount);
    if (packetCount > 0) {
      [peripheral readValueForCharacteristic:packetRxCharacteristic];
    }
  }
  
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  
  if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]]) {
    return;
  }
  
  if (characteristic.isNotifying) {
    NSLog(@"Notification began on %@", characteristic);
  } else {
    // Notification has stopped
  }
}

- (void)cleanup {
  NSLog(@"Entering cleanup");
  
  // See if we are subscribed to a characteristic on the peripheral
  if (self.myPeripheral.services != nil) {
    for (CBService *service in self.myPeripheral.services) {
      if (service.characteristics != nil) {
        for (CBCharacteristic *characteristic in service.characteristics) {
          if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]]) {
            if (characteristic.isNotifying) {
              [self.myPeripheral setNotifyValue:NO forCharacteristic:characteristic];
              return;
            }
          }
        }
      }
    }
  }
  
  packetRxCharacteristic = nil;
  packetTxCharacteristic = nil;
  txTriggerCharacteristic = nil;
  packetRssiCharacteristic = nil;
  batteryCharacteristic = nil;
}

   


@end
