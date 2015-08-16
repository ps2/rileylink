//
//  MySentryPairingViewController.h
//  RileyLink
//
//  Created by Nathan Racklyeft on 8/14/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RileyLinkBLEDevice.h"

@interface MySentryPairingViewController : UIViewController

@property (nonatomic, strong) RileyLinkBLEDevice *device;

@end
