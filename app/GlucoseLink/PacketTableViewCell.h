//
//  PacketTableViewCell.h
//  RileyLink
//
//  Created by Pete Schwamb on 7/30/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MinimedPacket.h"

@interface PacketTableViewCell : UITableViewCell

@property (nonatomic, strong) MinimedPacket *packet;

@end
