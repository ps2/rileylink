//
//  RileyLinkDevice.h
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RileyLinkDevice : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *RSSI;
@property (nonatomic, strong) NSString *identifier;

@end
