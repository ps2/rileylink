//
//  RileyLink.h
//  RileyLink
//
//  Created by Pete Schwamb on 8/5/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinimedPacket.h"
#import "RileyLinkBLEDevice.h"

#define RILEY_LINK_EVENT_LIST_UPDATED        @"RILEY_LINK_EVENT_LIST_UPDATED"
#define RILEY_LINK_EVENT_PACKET_RECEIVED     @"RILEY_LINK_EVENT_PACKET_RECEIVED"
#define RILEY_LINK_EVENT_DEVICE_DISCONNECTED @"RILEY_LINK_EVENT_DEVICE_DISCONNECTED"

#define GLUCOSELINK_SERVICE_UUID       @"d39f1890-17eb-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_BATTERY_SERVICE    @"180f"

#define GLUCOSELINK_RX_PACKET_UUID     @"2fb1a490-1940-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_CHANNEL_UUID       @"d93b2af0-1ea8-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_PACKET_COUNT       @"41825a20-7402-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_TX_PACKET_UUID     @"2fb1a490-1941-11e4-8c21-0800200c9a66"
#define GLUCOSELINK_TX_TRIGGER_UUID    @"2fb1a490-1942-11e4-8c21-0800200c9a66"

#define GLUCOSELINK_BATTERY_UUID       @"2A19"


@protocol RileyLinkDelegate;

@interface RileyLinkBLEManager : NSObject

- (void)stop;
- (void)sendPacket:(MinimedPacket*)packet;
- (NSArray*)rileyLinkList;
- (void)connectToRileyLink:(RileyLinkBLEDevice *)device;

+ (id)sharedManager;

@property (nonatomic, weak) id<RileyLinkDelegate> delegate;
@property (nonatomic, strong) NSArray *autoConnectIds;

@end

