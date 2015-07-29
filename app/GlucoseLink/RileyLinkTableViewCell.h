//
//  RileyLinkTableViewCell.h
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RileyLinkRecord.h"

@interface RileyLinkTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *RSSI;
@property (nonatomic, assign) BOOL autoConnect;
@property (nonatomic, assign) BOOL visible;

@end
