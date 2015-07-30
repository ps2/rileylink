//
//  RileyLinkViewController.h
//  RileyLink
//
//  Created by Pete Schwamb on 7/26/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RileyLinkBLEDevice.h"
#import "RileyLinkRecord.h"

@interface RileyLinkStatusViewController : UIViewController

@property (nonatomic, strong) RileyLinkBLEDevice *rlDevice;
@property (nonatomic, strong) RileyLinkRecord *rlRecord;

@end
