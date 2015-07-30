//
//  RileyLink.h
//  RileyLink
//
//  Created by Pete Schwamb on 8/5/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinimedPacket.h"

#define RILEY_LINK_EVENT_LIST_UPDATED @"RILEY_LINK_EVENT_LIST_UPDATED"

@protocol RileyLinkDelegate;

@interface RileyLinkBLEManager : NSObject

- (void)stop;
- (void)sendPacket:(MinimedPacket*)packet;
- (NSArray*)rileyLinkList;

+ (id)sharedManager;

@property (nonatomic, weak) id<RileyLinkDelegate> delegate;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, assign) unsigned char channel;
@property (nonatomic, strong) NSArray *autoConnectIds;

@end


@protocol RileyLinkDelegate <NSObject>

- (void)rileyLink:(RileyLinkBLEManager*)rileyLink
             didReceivePacket:(MinimedPacket*)packet;

- (void)rileyLink:(RileyLinkBLEManager*)rileyLink updatedStatus:(NSDictionary*)status;


@end