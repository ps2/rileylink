//
//  RileyLinkViewController.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/26/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "RileyLinkDeviceViewController.h"
#import "PacketLogViewController.h"
#import "PumpChatViewController.h"
#import "PacketGeneratorViewController.h"
#import "RileyLinkBLEManager.h"

@interface RileyLinkDeviceViewController () {
  IBOutlet UILabel *deviceIDLabel;
  IBOutlet UILabel *nameLabel;
  IBOutlet UISwitch *autoConnectSwitch;
  IBOutlet UIActivityIndicatorView *connectingIndicator;
}

@end

@implementation RileyLinkDeviceViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  deviceIDLabel.text = self.rlRecord.peripheralId;
  nameLabel.text = self.rlRecord.name;
  
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(deviceDisconnected:)
                                               name:RILEY_LINK_EVENT_DEVICE_DISCONNECTED
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(deviceConnected:)
                                               name:RILEY_LINK_EVENT_DEVICE_CONNECTED
                                             object:nil];


  [self updateConnectedHighlight];
  autoConnectSwitch.on = [self.rlRecord.autoConnect boolValue];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)updateConnectedHighlight {
  switch (self.rlDevice.state) {
    case RILEY_LINK_STATE_CONNECTING:
      nameLabel.backgroundColor = [UIColor clearColor];
      nameLabel.text = @"Connecting...";
      [connectingIndicator startAnimating];
      break;
    case RILEY_LINK_STATE_CONNECTED:
      nameLabel.backgroundColor = [UIColor greenColor];
      nameLabel.text = self.rlDevice.name;
      [connectingIndicator stopAnimating];
      break;
    case RILEY_LINK_STATE_DISCONNECTED:
      nameLabel.backgroundColor = [UIColor clearColor];
      nameLabel.text = self.rlDevice.name;
      [connectingIndicator stopAnimating];
      break;
  }
}

- (void)deviceDisconnected:(NSNotification*)notification {
  NSDictionary *attrs = notification.object;
  if (attrs[@"device"] == self.rlDevice) {
    [self updateConnectedHighlight];
  }
}

- (void)deviceConnected:(NSNotification*)notification {
  NSDictionary *attrs = notification.object;
  if (attrs[@"device"] == self.rlDevice) {
    [self updateConnectedHighlight];
  }
}


- (IBAction)autoConnectSwitchToggled:(id)sender {
  self.rlRecord.autoConnect = [NSNumber numberWithBool:autoConnectSwitch.on];
  NSError *error;
  if (![self.managedObjectContext save:&error]) {
    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
  }
  
  if (autoConnectSwitch.on) {
    [self.rlDevice connect];
  } else {
    [self.rlDevice disconnect];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.destinationViewController respondsToSelector:@selector(setDevice:)]) {
      [segue.destinationViewController performSelector:@selector(setDevice:) withObject:self.rlDevice];
  }
}

@end
