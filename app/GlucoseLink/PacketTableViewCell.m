//
//  PacketTableViewCell.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/30/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "PacketTableViewCell.h"

@interface PacketTableViewCell () {
  IBOutlet UILabel *rawDataLabel;
}

@end

@implementation PacketTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setPacket:(MinimedPacket *)packet {
  _packet = packet;
  
  rawDataLabel.text = packet.hexadecimalString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
