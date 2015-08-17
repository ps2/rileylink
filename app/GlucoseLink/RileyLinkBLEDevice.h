//
//  RileyLinkBLE.h
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


typedef enum {
  RILEY_LINK_STATE_CONNECTING,
  RILEY_LINK_STATE_CONNECTED,
  RILEY_LINK_STATE_DISCONNECTED
} RileyLinkState;

@interface RileyLinkBLEDevice : NSObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * RSSI;
@property (nonatomic, retain) NSString * peripheralId;
@property (nonatomic, retain) id peripheral;

- (NSArray*) packets;

- (RileyLinkState) state;
- (void) connect;
- (void) disconnect;
- (void) cancelSending;
- (void) setRXChannel:(unsigned char)channel;
- (void) setTXChannel:(unsigned char)channel;
- (void) sendPacketData:(NSData*)data;
- (void) sendPacketData:(NSData*)data withCount:(NSInteger)count andTimeBetweenPackets:(NSTimeInterval)timeBetweenPackets;

@end
