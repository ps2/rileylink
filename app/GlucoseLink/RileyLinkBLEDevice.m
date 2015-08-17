//
//  RileyLinkBLE.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "MinimedPacket.h"
#import "RileyLinkBLEDevice.h"
#import "RileyLinkBLEManager.h"
#import "NSData+Conversion.h"
#import "SendDataTask.h"

@interface RileyLinkBLEDevice () <CBPeripheralDelegate> {
  CBCharacteristic *packetRxCharacteristic;
  CBCharacteristic *packetTxCharacteristic;
  CBCharacteristic *txTriggerCharacteristic;
  CBCharacteristic *packetRssiCharacteristic;
  CBCharacteristic *batteryCharacteristic;
  CBCharacteristic *packetCountCharacteristic;
  CBCharacteristic *txChannelCharacteristic;
  CBCharacteristic *rxChannelCharacteristic;
  NSMutableArray *incomingPackets;
  NSMutableArray *sendTasks;
  SendDataTask *currentSendTask;
  NSInteger copiesLeftToSend;
  NSTimer *sendTimer;
}

@end


@implementation RileyLinkBLEDevice

- (instancetype)init
{
  self = [super init];
  if (self) {
    incomingPackets = [NSMutableArray array];
    sendTasks = [NSMutableArray array];
    currentSendTask = nil;
  }
  return self;
}

- (NSArray*) packets {
  return incomingPackets;
}

- (void) sendPacketData:(NSData*)data {
  [self sendPacketData:data withCount:1 andTimeBetweenPackets:0];
}

- (void) sendPacketData:(NSData*)data withCount:(NSInteger)count andTimeBetweenPackets:(NSTimeInterval)timeBetweenPackets {
  if (count <= 0) {
    NSLog(@"Invalid repeat count for sendPacketData");
    return;
  }
  SendDataTask *task = [[SendDataTask alloc] init];
  task.data = data;
  task.repeatCount = count;
  task.timeBetweenPackets = timeBetweenPackets;
  [sendTasks addObject:task];
  [self dequeueSendTasks];
}

- (void) dequeueSendTasks {
  if (!currentSendTask && sendTasks.count > 0) {
    currentSendTask = sendTasks[0];
    copiesLeftToSend = currentSendTask.repeatCount;
    [sendTasks removeObjectAtIndex:0];
    NSLog(@"Prepping for send: %@", [currentSendTask.data hexadecimalString]);
    [self.peripheral writeValue:currentSendTask.data forCharacteristic:packetTxCharacteristic type:CBCharacteristicWriteWithResponse];
  }
}

- (void) triggerSend {
  if (copiesLeftToSend > 0) {
    NSLog(@"Sending copy %ld", (currentSendTask.repeatCount - copiesLeftToSend) + 1);
    NSData *trigger = [NSData dataWithHexadecimalString:@"01"];
    [self.peripheral writeValue:trigger forCharacteristic:txTriggerCharacteristic type:CBCharacteristicWriteWithResponse];
    copiesLeftToSend--;
  }
  
  if (copiesLeftToSend > 0) {
    if (!sendTimer) {
      sendTimer = [NSTimer timerWithTimeInterval:currentSendTask.timeBetweenPackets target:self selector:@selector(triggerSend) userInfo:nil repeats:YES];
      [[NSRunLoop currentRunLoop] addTimer:sendTimer forMode:NSRunLoopCommonModes];
    }
  }
  else {
    currentSendTask = nil;
    [sendTimer invalidate];
    sendTimer = nil;
  }
}

- (void) cancelSending {
  [sendTimer invalidate];
  sendTimer = nil;
  copiesLeftToSend = 0;
  currentSendTask = nil;
}

- (void) setRXChannel:(unsigned char)channel {
  if (rxChannelCharacteristic) {
    NSData *data = [NSData dataWithBytes:&channel length:1];
    [self.peripheral writeValue:data forCharacteristic:rxChannelCharacteristic type:CBCharacteristicWriteWithResponse];
  } else {
    NSLog(@"Missing rx channel characteristic");
  }
}

- (void) setTXChannel:(unsigned char)channel {
  if (rxChannelCharacteristic) {
    NSData *data = [NSData dataWithBytes:&channel length:1];
    [self.peripheral writeValue:data forCharacteristic:txChannelCharacteristic type:CBCharacteristicWriteWithResponse];
  } else {
    NSLog(@"Missing tx channel characteristic");    
  }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  if (error) {
    NSLog(@"Could not write characteristic: %@", error);
    return;
  }
  if (characteristic == packetTxCharacteristic) {
    [self triggerSend];
  }
  NSLog(@"Did write characteristic: %@", characteristic);
}

- (BOOL) isConnected {
  return self.peripheral.state == CBPeripheralStateConnected;
}

- (void) setPeripheral:(CBPeripheral *)peripheral {
  _peripheral = peripheral;
    peripheral.delegate = self;

    for (CBService *service in peripheral.services) {
        [self setCharacteristicsFromService:service];
    }
}

- (void) connect {
  [[RileyLinkBLEManager sharedManager] connectToRileyLink:self];
}

- (void) disconnect {
  [[RileyLinkBLEManager sharedManager] disconnectRileyLink:self];
}

   
- (void)updateBatteryLevel {
  [self.peripheral readValueForCharacteristic:batteryCharacteristic];
  [self.peripheral readRSSI];
}

- (void)setCharacteristicsFromService:(CBService *)service {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]]) {
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            packetCountCharacteristic = characteristic;
            [self.peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_RX_CHANNEL_UUID]]) {
            rxChannelCharacteristic = characteristic;
            [self setRXChannel:2];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_TX_CHANNEL_UUID]]) {
            txChannelCharacteristic = characteristic;
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

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  if (error) {
    NSLog(@"Failure while discovering services: %@", error);
    return;
  }
  NSLog(@"didDiscoverServices: %@, %@", peripheral, peripheral.services);
  for (CBService *service in peripheral.services) {
    if ([service.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_BATTERY_SERVICE]]) {
      [peripheral discoverCharacteristics:[RileyLinkBLEManager UUIDsFromUUIDStrings:@[GLUCOSELINK_BATTERY_UUID]
                                                                excludingAttributes:service.characteristics]
                               forService:service];
    } else if ([service.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID]]) {
        [peripheral discoverCharacteristics:[RileyLinkBLEManager UUIDsFromUUIDStrings:@[GLUCOSELINK_RX_PACKET_UUID,
                                                                                        GLUCOSELINK_RX_CHANNEL_UUID,
                                                                                        GLUCOSELINK_TX_CHANNEL_UUID,
                                                                                        GLUCOSELINK_PACKET_COUNT,
                                                                                        GLUCOSELINK_TX_PACKET_UUID,
                                                                                        GLUCOSELINK_TX_TRIGGER_UUID]
                                                                excludingAttributes:service.characteristics]
                               forService:service];
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

    [self setCharacteristicsFromService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  if (error) {
    NSLog(@"Error updating %@: %@", characteristic, error);
    return;
  }
  //NSLog(@"didUpdateValueForCharacteristic: %@", characteristic);
  
  if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_RX_PACKET_UUID]]) {
    if (characteristic.value.length > 0) {
      MinimedPacket *packet = [[MinimedPacket alloc] initWithData:characteristic.value];
      packet.capturedAt = [NSDate date];
      //if ([packet isValid]) {
      [incomingPackets addObject:packet];
      NSLog(@"Read packet (%d): %@", packet.rssi, packet.data.hexadecimalString);
      NSDictionary *attrs = @{
                              @"packet": packet,
                              @"peripheral": self.peripheral
                              };
      [[NSNotificationCenter defaultCenter] postNotificationName:RILEY_LINK_EVENT_PACKET_RECEIVED object:self userInfo:attrs];
    }
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
  if (self.peripheral.services != nil) {
    for (CBService *service in self.peripheral.services) {
      if (service.characteristics != nil) {
        for (CBCharacteristic *characteristic in service.characteristics) {
          if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]]) {
            if (characteristic.isNotifying) {
              [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
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
