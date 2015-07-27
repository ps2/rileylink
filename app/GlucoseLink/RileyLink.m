//
//  RileyLink.m
//  RileyLink
//
//  Created by Pete Schwamb on 8/5/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import "RileyLink.h"
#import "MinimedPacket.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define GLUCOSELINK_SERVICE_UUID       @"d39f1890-17eb-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_BATTERY_SERVICE    @"180f"

#define GLUCOSELINK_RX_PACKET_UUID     @"2fb1a490-1940-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_CHANNEL_UUID       @"d93b2af0-1ea8-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_PACKET_COUNT       @"41825a20-7402-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_TX_PACKET_UUID     @"2fb1a490-1941-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_TX_TRIGGER_UUID    @"2fb1a490-1942-11e4-8c21-0800200c9a66"

#define GLUCOSELINK_BATTERY_UUID       @"2A19"

static NSDateFormatter *iso8601Formatter;

@interface RileyLink () <CBCentralManagerDelegate, CBPeripheralDelegate> {
  NSTimer *timer;
  NSInteger rssi;
  NSInteger batteryPct;
  NSMutableArray *outgoingQueue;
}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;
@property (assign, nonatomic) BOOL didSetChannel;
@property (strong, nonatomic) CBCharacteristic *packetRxCharacteristic;
@property (strong, nonatomic) CBCharacteristic *packetTxCharacteristic;
@property (strong, nonatomic) CBCharacteristic *txTriggerCharacteristic;
@property (strong, nonatomic) CBCharacteristic *packetRssiCharacteristic;
@property (strong, nonatomic) CBCharacteristic *batteryCharacteristic;
@property (strong, nonatomic) CBCharacteristic *packetCountCharacteristic;

@end


@implementation RileyLink

+ (void)initialize {
  iso8601Formatter = [[NSDateFormatter alloc] init];
  [iso8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _data = [[NSMutableData alloc] init];
    _connected = NO;
    NSTimer *statusUpdateTimer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(updateStatus) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:statusUpdateTimer forMode:NSDefaultRunLoopMode];
    rssi = 0;
    batteryPct = 0;
    outgoingQueue = [NSMutableArray array];
    [self updateStatus];
  }
  return self;
}

- (void)stop {
  NSLog(@"Stopping scan");
  [_centralManager stopScan];
}

- (void)sendPacket:(MinimedPacket*)packet {
  [outgoingQueue addObject:packet];
}

- (void)flushOutgoingQueue {
  if (outgoingQueue.count > 0 && _connected && _packetTxCharacteristic) {
    // TODO
    //[_packetTxCharacteristic ]
  }
}


- (void)updateStatus {
  NSMutableDictionary *status = [NSMutableDictionary dictionary];
  [status setObject:(_connected ? @YES : @NO) forKey:@"connected"];
  [status setObject:[NSNumber numberWithInt:rssi] forKey:@"rssi"];
  [status setObject:[NSNumber numberWithInt:batteryPct] forKey:@"batteryPct"];
  [status setObject:[iso8601Formatter stringFromDate:[NSDate date]] forKey:@"updatedAt"];
  [self.delegate rileyLink:self updatedStatus:status];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  // You should test all scenarios
  if (central.state != CBCentralManagerStatePoweredOn) {
    return;
  }
  
  if (central.state == CBCentralManagerStatePoweredOn) {
    // Scan for devices
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID]] options:NULL];
    NSLog(@"Scanning started (state = powered on)");
  }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  
  NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
  rssi = [RSSI integerValue];
  
  if (_discoveredPeripheral != peripheral) {
    // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
    _discoveredPeripheral = peripheral;
    
    // And connect
    NSLog(@"Connecting to peripheral %@", peripheral);
    [_centralManager connectPeripheral:peripheral options:nil];
  }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  NSLog(@"Failed to connect");
  [self cleanup];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  NSLog(@"Connected");
  _didSetChannel = NO;
  _connected = YES;
  [self updateStatus];
  
  [_centralManager stopScan];
  NSLog(@"Scanning stopped");
  
  [_data setLength:0];
  
  peripheral.delegate = self;
  
  NSLog(@"Discovering services");
  [peripheral discoverServices:@[[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID],
                                 [CBUUID UUIDWithString:GLUCOSELINK_BATTERY_SERVICE]]];
}

- (void)restartScan {
  NSLog(@"Restarting scan.");
  [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  if (error) {
    NSLog(@"Failure while discovering services: %@", error);
    [self cleanup];
    [self restartScan];
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
  if (error) {
    NSLog(@"Could not get rssi: %@", error);
    rssi = 0;
  } else {
    rssi = RSSI.integerValue;
  }
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
      _packetCountCharacteristic = characteristic;
      [peripheral readValueForCharacteristic:characteristic];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_CHANNEL_UUID]] && !_didSetChannel) {
      NSData *data = [NSMutableData dataWithBytes:&_channel length:sizeof(_channel)];
      [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_RX_PACKET_UUID]]) {
      _packetRxCharacteristic = characteristic;
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_TX_PACKET_UUID]]) {
      _packetTxCharacteristic = characteristic;
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_TX_TRIGGER_UUID]]) {
      _txTriggerCharacteristic = characteristic;
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_BATTERY_UUID]]) {
      _batteryCharacteristic = characteristic;
    }
  }
  
  if (_batteryCharacteristic != nil && timer == nil) {
    [peripheral readRSSI];
    timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(updateBatteryLevel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [self updateBatteryLevel];
  }
}

- (void)updateBatteryLevel {
  [_discoveredPeripheral readValueForCharacteristic:_batteryCharacteristic];
  [_discoveredPeripheral readRSSI];
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
      [_delegate rileyLink:self didReceivePacket:packet];
    //} else {
    //  NSLog(@"Invalid packet: %@", [packet hexadecimalString]);
    //}
    [peripheral readValueForCharacteristic:_packetCountCharacteristic];

  } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_BATTERY_UUID]]) {
    batteryPct = ((const unsigned char*)[characteristic.value bytes])[0];
    NSLog(@"Updated battery pct: %d", batteryPct);
  } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]]) {
    const unsigned char packetCount = ((const unsigned char*)[characteristic.value bytes])[0];
    NSLog(@"Updated packet count: %d", packetCount);
    if (packetCount > 0) {
      [peripheral readValueForCharacteristic:_packetRxCharacteristic];
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
    [_centralManager cancelPeripheralConnection:peripheral];
  }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  _discoveredPeripheral = nil;
  _connected = NO;
  [self updateStatus];
  
  if (error) {
    NSLog(@"Disconnected: %@", error);
  }

  [self restartScan];
}

- (void)cleanup {
  NSLog(@"Entering cleanup");
  
  // See if we are subscribed to a characteristic on the peripheral
  if (_discoveredPeripheral.services != nil) {
    for (CBService *service in _discoveredPeripheral.services) {
      if (service.characteristics != nil) {
        for (CBCharacteristic *characteristic in service.characteristics) {
          if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GLUCOSELINK_PACKET_COUNT]]) {
            if (characteristic.isNotifying) {
              [_discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
              return;
            }
          }
        }
      }
    }
  }
  
  [_centralManager cancelPeripheralConnection:_discoveredPeripheral];
  
  _discoveredPeripheral = nil;
  _packetRxCharacteristic = nil;
  _packetTxCharacteristic = nil;
  _txTriggerCharacteristic = nil;
  _packetRssiCharacteristic = nil;
  _batteryCharacteristic = nil;
  
  [timer invalidate];
  timer = nil;
}



@end
