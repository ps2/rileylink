//
//  MinimedPacket.h
//  GlucoseLink
//
//  Created by Pete Schwamb on 8/5/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MinimedPacket : NSObject

typedef enum {
  PACKET_TYPE_PUMP = 0xa2,
  PACKET_TYPE_METER = 0xa5,
  PACKET_TYPE_SENSOR = 0xa8
} PacketType;

typedef enum {
  MESSAGE_TYPE_ALERT = 0x01,
  MESSAGE_TYPE_ALERT_CLEARED = 0x02,
  MESSAGE_TYPE_DEVICE_TEST = 0x03,
  MESSAGE_TYPE_PUMP_STATUS = 0x04,
  MESSAGE_TYPE_PUMP_STATUS_ACK = 0x06,
  MESSAGE_TYPE_PUMP_BACKFILL = 0x08,
  MESSAGE_TYPE_FIND_DEVICE = 0x09,
  MESSAGE_TYPE_DEVICE_LINK = 0x0a,
  MESSAGE_TYPE_PUMP_DUMP = 0x0a,
  MESSAGE_TYPE_GET_PUMP_MODEL = 0x8d,
} MessageType;


- (instancetype)initWithData:(NSData*)data;
- (BOOL) isValid;
- (NSString*) hexadecimalString;
- (PacketType) packetType;
- (MessageType) messageType;
- (NSString*) address;
+ (NSData*)encodeData:(NSData*)data;

@property (strong, nonatomic) NSData *data;
@property (nonatomic, strong) NSDate *capturedAt;
@property (nonatomic, assign) int rssi;
@property (nonatomic, assign) int packetNumber;

@end
