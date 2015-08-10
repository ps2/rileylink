//
//  SendDataParams.h
//  RileyLink
//
//  Created by Pete Schwamb on 8/9/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendDataTask : NSObject


@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, assign) NSTimeInterval timeBetweenPackets;

@end
