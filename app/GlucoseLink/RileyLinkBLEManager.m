//
//  RileyLink.m
//  RileyLink
//
//  Created by Pete Schwamb on 8/5/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import "RileyLinkBLEManager.h"
#import "MinimedPacket.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "RileyLinkBLEDevice.h"
#import "CBPeripheral+UUIDString.h"

static NSDateFormatter *iso8601Formatter;

@interface RileyLinkBLEManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
  NSTimer *timer;
  NSMutableArray *outgoingQueue;
  NSMutableDictionary *peripheralsById; // CBPeripherals by UUID
  NSMutableDictionary *devicesById; // RileyLinkBLEDevices by UUID
}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableData *data;

@end


@implementation RileyLinkBLEManager


+ (id)sharedManager {
  static RileyLinkBLEManager *sharedMyRileyLink = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyRileyLink = [[self alloc] init];
  });
  return sharedMyRileyLink;
}


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
    outgoingQueue = [NSMutableArray array];
    
    peripheralsById = [NSMutableDictionary dictionary];
    devicesById = [NSMutableDictionary dictionary];
  }
  return self;
}

- (RileyLinkBLEDevice*) newRileyLinkFromPeripheral:(CBPeripheral*)peripheral {
  RileyLinkBLEDevice *device = [[RileyLinkBLEDevice alloc] init];
  device.name = peripheral.name;
  device.peripheralId = peripheral.UUIDString;
  return device;
}

- (void)stop {
  NSLog(@"Stopping scan");
  [_centralManager stopScan];
}

- (void)sendPacket:(MinimedPacket*)packet {
  [outgoingQueue addObject:packet];
}

- (void)flushOutgoingQueue {
  if (outgoingQueue.count > 0) {
    // TODO
    //[_packetTxCharacteristic ]
  }
}

- (void) sendNotice:(NSString*)name {
  [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
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

- (NSArray*)rileyLinkList {
  return [devicesById allValues];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  
  NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
  
  peripheralsById[peripheral.UUIDString] = peripheral;
  
  RileyLinkBLEDevice *d = devicesById[peripheral.UUIDString];
  if (devicesById[peripheral.UUIDString] == NULL) {
    d = [self newRileyLinkFromPeripheral:peripheral];
    devicesById[peripheral.UUIDString] = d;
  }
  d.RSSI = RSSI;
  d.name = peripheral.name;
  d.peripheral = peripheral;
  
  [self sendNotice:RILEY_LINK_EVENT_LIST_UPDATED];
  
  if ([self.autoConnectIds indexOfObject:d.peripheralId]) {
    [self connectToRileyLink:d];
  }
  
}

- (void)addDeviceToAutoConnectList:(RileyLinkBLEDevice*)device {
  self.autoConnectIds = [self.autoConnectIds arrayByAddingObject:device.peripheralId];
}

- (void)removeDeviceFromAutoConnectList:(RileyLinkBLEDevice*)device {
  NSMutableArray *mutableList = [self.autoConnectIds mutableCopy];
  [mutableList removeObject:device.peripheralId];
  self.autoConnectIds = mutableList;
}

- (void)connectToRileyLink:(RileyLinkBLEDevice *)device {
  NSLog(@"Connecting to peripheral %@", device.peripheral);
  [_centralManager connectPeripheral:device.peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  NSLog(@"Failed to connect to peripheral: %@", error);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  
  NSLog(@"Discovering services");
  [peripheral discoverServices:@[[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID],
                                 [CBUUID UUIDWithString:GLUCOSELINK_BATTERY_SERVICE]]];
}

- (void)restartScan {
  NSLog(@"Restarting scan.");
  [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  
  if (error) {
    NSLog(@"Disconnection error: %@", error);
  }
  
  NSDictionary *attrs = @{
                          @"peripheral": peripheral,
                          @"device": devicesById[peripheral.UUIDString],
                          @"error": error
                          };
  [[NSNotificationCenter defaultCenter] postNotificationName:RILEY_LINK_EVENT_DEVICE_DISCONNECTED object:attrs];
}



@end
