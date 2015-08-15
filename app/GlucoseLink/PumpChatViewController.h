//
//  PumpChatViewController.h
//  RileyLink
//
//  Created by Pete Schwamb on 8/8/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RileyLinkBLEDevice.h"

@interface PumpChatViewController : UIViewController

@property (nonatomic, strong) RileyLinkBLEDevice *device;

@end
