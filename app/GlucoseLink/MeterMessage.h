//
//  MeterMessage.h
//  GlucoseLink
//
//  Created by Pete Schwamb on 5/30/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageBase.h"

@interface MeterMessage : MessageBase

@property (nonatomic, strong) NSDate *dateReceived;

- (NSInteger) glucose;

@end
