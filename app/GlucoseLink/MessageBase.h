//
//  MessageBase.h
//  GlucoseLink
//
//  Created by Pete Schwamb on 5/26/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageBase : NSObject

@property (strong, nonatomic) NSData *data;

- (instancetype)initWithData:(NSData*)data;
- (NSDictionary*) bitBlocks;
- (NSInteger) b:(NSString*)key;
- (unsigned char) getBitAtIndex:(NSInteger)idx;

@end
