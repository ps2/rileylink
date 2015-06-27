//
//  NightScoutUploader.h
//  GlucoseLink
//
//  Created by Pete Schwamb on 5/23/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinimedPacket.h"

@interface NightScoutUploader : NSObject

- (void)reportToNightScout:(NSArray*)entries
         completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (void)addPacket:(MinimedPacket*)packet;

@property (nonatomic, strong) NSString *endpoint;
@property (nonatomic, strong) NSString *APISecret;


@end
