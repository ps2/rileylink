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
}

@end


@implementation RileyLinkTableViewCell

- (void)setRileyLink:(RileyLinkDevice *)rileyLink {
  _rileyLink = rileyLink;
  
  nameLabel.text = rileyLink.name;
  rssiLabel.text = [rileyLink.RSSI stringValue];
}


@end
