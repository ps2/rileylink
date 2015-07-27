//
//  RileyLink.h
//  RileyLink
//
//  Created by Pete Schwamb on 8/5/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinimedPacket.h"

@protocol RileyLinkDelegate;

@interface RileyLink : NSObject

- (void)stop;
- (void)sendPacket:(MinimedPacket*)packet;

@property (nonatomic, weak) id<RileyLinkDelegate> delegate;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, assign) unsigned char channel;

@end


@protocol RileyLinkDelegate <NSObject>

- (void)rileyLink:(RileyLink*)rileyLink
             didReceivePacket:(MinimedPacket*)packet;

- (void)rileyLink:(RileyLink*)rileyLink updatedStatus:(NSDictionary*)status;


@end