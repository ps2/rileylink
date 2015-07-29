//
//  MainAppViewController.m
//  RileyLink
//
//  Created by Pete Schwamb on 6/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "RileyLinkBLEManager.h"
#import "NSData+Conversion.h"
#import "PumpStatusMessage.h"
#import "ISO8601DateFormatter.h"
#import "NightScoutUploader.h"
#import "Config.h"

#import "MainAppViewController.h"

@interface MainAppViewController () <RileyLinkDelegate> {
  NSDictionary *lastStatus;
}

@property (strong, nonatomic) ISO8601DateFormatter *dateFormatter;
@property (strong, nonatomic) NSTimeZone *utcTimeZone;
@property (strong, nonatomic) NightScoutUploader *uploader;


@end

@implementation MainAppViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [[RileyLinkBLEManager sharedManager] setChannel:2];
  [[RileyLinkBLEManager sharedManager] setDelegate:self];
  
  _dateFormatter = [[ISO8601DateFormatter alloc] init];
  _dateFormatter.includeTime = YES;
  _dateFormatter.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
  
  self.uploader = [[NightScoutUploader alloc] init];
  self.uploader.endpoint = [[Config sharedInstance] nightscoutURL];
  self.uploader.APISecret = [[Config sharedInstance] nightscoutAPISecret];
  
  //[self.uploader test];
  //[self performSelector:@selector(generateMockData) withObject:nil afterDelay:2];
}

- (void)generateMockData {
  NSData *bgPacket = [NSData dataWithHexadecimalString:@"0000a5c527ad00f111"];
  MinimedPacket *packet = [[MinimedPacket alloc] initWithData:bgPacket];
  packet.capturedAt = [NSDate date];
  [self rileyLink:nil didReceivePacket:packet];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [[RileyLinkBLEManager sharedManager] stop];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GlucoseLinkDelegate methods

- (void)rileyLink:(RileyLinkBLEManager *)rileyLink didReceivePacket:(MinimedPacket*)packet {
  [self.uploader addPacket:packet];
}

- (void)rileyLink:(RileyLinkBLEManager *)rileyLink updatedStatus:(NSDictionary*)status {
  lastStatus = status;
  // TODO: find place to display, now that we're using nightscout
}



@end
