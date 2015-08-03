//
//  PacketTableViewCell.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/30/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "PacketTableViewCell.h"

static NSDateFormatter *dateFormatter;
static NSDateFormatter *timeFormatter;

@interface PacketTableViewCell () {
  IBOutlet UILabel *rawDataLabel;
  IBOutlet UILabel *dateLabel;
  IBOutlet UILabel *timeLabel;
  IBOutlet UILabel *rssiLabel;
  IBOutlet UILabel *packetNumberLabel;
}

@end

@implementation PacketTableViewCell

+ (void)initialize {
  dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setLocale:[NSLocale currentLocale]];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  timeFormatter = [[NSDateFormatter alloc] init];
  [timeFormatter setLocale:[NSLocale currentLocale]];
  [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setPacket:(MinimedPacket *)packet {
  _packet = packet;
  
  rawDataLabel.text = packet.hexadecimalString;
  dateLabel.text = [dateFormatter stringFromDate:packet.capturedAt];
  timeLabel.text = [timeFormatter stringFromDate:packet.capturedAt];
  rssiLabel.text = [NSString stringWithFormat:@"%d", packet.rssi];
  packetNumberLabel.text = [NSString stringWithFormat:@"#%d", packet.packetNumber];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
