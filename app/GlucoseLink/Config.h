//
//  Config.h
//  RileyLink
//
//  Created by Pete Schwamb on 6/27/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject {
  NSUserDefaults *_defaults;
}

+ (Config *)sharedInstance;

@property (nonatomic, strong) NSString *nightscoutURL;
@property (nonatomic, strong) NSString *nightscoutAPISecret;

- (BOOL) hasValidConfiguration;

@end
