//
//  RileyLinkTableViewCell.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "RileyLinkTableViewCell.h"

@interface RileyLinkTableViewCell () {
  IBOutlet UILabel *nameLabel;
  IBOutlet UILabel *rssiLabel;
  IBOutlet UILabel *statusLabel;
}

@end


@implementation RileyLinkTableViewCell

- (void)setName:(NSString *)name {
  _name = name;
  nameLabel.text = name;
}

- (void)setRSSI:(NSNumber *)RSSI {
  _RSSI = RSSI;
  rssiLabel.text = [RSSI stringValue];
}

- (void)setAutoConnect:(BOOL)autoConnect {
  _autoConnect = autoConnect;
  if (autoConnect) {
    statusLabel.text = @"Auto-connect enabled";
  } else {
    statusLabel.text = @"";
  }
}

- (void)setVisible:(BOOL)visible {
  _visible = visible;
  nameLabel.enabled = visible;
}

@end
