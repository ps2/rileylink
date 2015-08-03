//
//  RileyLinkViewController.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/26/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "RileyLinkDeviceViewController.h"
#import "PacketLogViewController.h"

@interface RileyLinkDeviceViewController () {
  IBOutlet UILabel *deviceIDLabel;
  IBOutlet UILabel *nameLabel;
  IBOutlet UISwitch *autoConnectSwitch;
}

@end

@implementation RileyLinkDeviceViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  deviceIDLabel.text = self.rlRecord.peripheralId;
  nameLabel.text = self.rlRecord.name;
  if (self.rlDevice && self.rlDevice.isConnected) {
    nameLabel.backgroundColor = [UIColor greenColor];
  } else {
    nameLabel.backgroundColor = [UIColor clearColor];
  }
  
  autoConnectSwitch.on = [self.rlRecord.autoConnect boolValue];

  //[self.rlDevice connect];
}

- (IBAction)autoConnectSwitchToggled:(id)sender {
  self.rlRecord.autoConnect = [NSNumber numberWithBool:autoConnectSwitch.on];
  NSError *error;
  if (![self.managedObjectContext save:&error]) {
    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
  }
  
  if (autoConnectSwitch.on) {
    [self.rlDevice connect];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  PacketLogViewController *c = (PacketLogViewController*) [segue destinationViewController];
  c.device = self.rlDevice;
}

@end
