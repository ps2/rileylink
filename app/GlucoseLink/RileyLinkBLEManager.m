//
//  RileyLink.m
//  RileyLink
//
//  Created by Pete Schwamb on 8/5/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import "RileyLinkBLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "RileyLinkBLEDevice.h"

static NSDateFormatter *iso8601Formatter;

@interface RileyLinkBLEManager () <CBCentralManagerDelegate> {
  NSTimer *reconnectTimer;
  NSMutableDictionary *devicesById; // RileyLinkBLEDevices by UUID
}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableData *data;

@end


@implementation RileyLinkBLEManager

+ (NSArray *)UUIDsFromUUIDStrings:(NSArray *)UUIDStrings
              excludingAttributes:(NSArray *)attributes {
  NSMutableArray *unmatchedUUIDStrings = [UUIDStrings mutableCopy];

  for (CBAttribute *attribute in attributes) {
    [unmatchedUUIDStrings removeObject:attribute.UUID.UUIDString];
  }

  NSMutableArray *UUIDs = [NSMutableArray array];

  for (NSString *UUIDString in unmatchedUUIDStrings) {
    [UUIDs addObject:[CBUUID UUIDWithString:UUIDString]];
  }

  return [NSArray arrayWithArray:UUIDs];
}

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
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                             queue:nil
                                                           options:@{CBCentralManagerOptionRestoreIdentifierKey: @"com.rileylink.CentralManager"}];
    _data = [[NSMutableData alloc] init];

    devicesById = [NSMutableDictionary dictionary];
  }
  return self;
}

- (RileyLinkBLEDevice*) newRileyLinkFromPeripheral:(CBPeripheral*)peripheral {
  RileyLinkBLEDevice *device = [[RileyLinkBLEDevice alloc] init];
  device.name = peripheral.name;
  device.peripheralId = peripheral.identifier.UUIDString;
  return device;
}

- (void)setScanningEnabled:(BOOL)scanningEnabled {
    if (scanningEnabled && _centralManager.state == CBCentralManagerStatePoweredOn) {
        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID]] options:NULL];
        NSLog(@"Scanning started (state = powered on)");
    } else if (!scanningEnabled || _centralManager.state == CBCentralManagerStatePoweredOff) {
        [_centralManager stopScan];
    }

    _scanningEnabled = scanningEnabled;
}

- (void) sendNotice:(NSString*)name {
  [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];

    for (CBPeripheral *peripheral in peripherals) {
        [self addPeripheralToDeviceList:peripheral];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.scanningEnabled = self.isScanningEnabled;

    if (central.state != CBCentralManagerStatePoweredOn && reconnectTimer.isValid) {
        [reconnectTimer invalidate];
        reconnectTimer = nil;
    }
}

- (NSArray*)rileyLinkList {
  return [devicesById allValues];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  
  NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);

  RileyLinkBLEDevice *device = [self addPeripheralToDeviceList:peripheral];

  device.RSSI = RSSI;

  [self sendNotice:RILEY_LINK_EVENT_LIST_UPDATED];
}

- (RileyLinkBLEDevice *)addPeripheralToDeviceList:(CBPeripheral *)peripheral {
  RileyLinkBLEDevice *d = devicesById[peripheral.identifier.UUIDString];
  if (devicesById[peripheral.identifier.UUIDString] == NULL) {
    d = [self newRileyLinkFromPeripheral:peripheral];
    devicesById[peripheral.identifier.UUIDString] = d;
  }
  d.name = peripheral.name;
  d.peripheral = peripheral;

  if ([self.autoConnectIds indexOfObject:d.peripheralId] != NSNotFound) {
    [self connectToRileyLink:d];
  }

  return d;
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

- (void)disconnectRileyLink:(RileyLinkBLEDevice *)device {
  NSLog(@"Disconnecting from peripheral %@", device.peripheral);
  [_centralManager cancelPeripheralConnection:device.peripheral];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  NSLog(@"Failed to connect to peripheral: %@", error);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

  NSLog(@"Discovering services");
  [peripheral discoverServices:[[self class] UUIDsFromUUIDStrings:@[GLUCOSELINK_SERVICE_UUID,
                                                                    GLUCOSELINK_BATTERY_SERVICE]
                                              excludingAttributes:peripheral.services]];

  NSDictionary *attrs = @{
                          @"peripheral": peripheral,
                          @"device": devicesById[peripheral.identifier.UUIDString]
                          };
  [[NSNotificationCenter defaultCenter] postNotificationName:RILEY_LINK_EVENT_DEVICE_CONNECTED object:attrs];
  
}

- (void)restartScan {
  NSLog(@"Restarting scan.");
  [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:GLUCOSELINK_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void)attemptReconnectForDisconnectedDevices {
  NSInteger reconnectCount = 0;

  for (RileyLinkBLEDevice *device in [self rileyLinkList]) {
    CBPeripheral *peripheral = device.peripheral;
    if (peripheral.state == CBPeripheralStateDisconnected
        && [self.autoConnectIds indexOfObject:device.peripheralId] != NSNotFound) {
      NSLog(@"Attempting reconnect to %@", device);
      [self connectToRileyLink:device];
      reconnectCount++;
    }
  }

  if (reconnectCount == 0 && reconnectTimer.isValid) {
    [reconnectTimer invalidate];
    reconnectTimer = nil;
  }
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  
  if (error) {
    NSLog(@"Disconnection: %@", error);
  }
  NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
  
  attrs[@"peripheral"] = peripheral;
  attrs[@"device"] = devicesById[peripheral.identifier.UUIDString];
  
  if (error) {
    attrs[@"error"] = error;
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:RILEY_LINK_EVENT_DEVICE_DISCONNECTED object:attrs];
  
  if (!reconnectTimer) {
    reconnectTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(attemptReconnectForDisconnectedDevices) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:reconnectTimer forMode:NSRunLoopCommonModes];
  }

}



@end
