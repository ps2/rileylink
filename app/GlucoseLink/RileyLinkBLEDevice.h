//
//  RileyLinkBLE.h
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RileyLinkBLEDevice : NSObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * peripheralId;
@property (nonatomic, retain) NSNumber * RSSI;

@end
