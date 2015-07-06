//
//  MainAppViewController.m
//  RileyLink
//
//  Created by Pete Schwamb on 6/28/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "RileyLink.h"
#import "NSData+Conversion.h"
#import "PumpStatusMessage.h"
#import "ISO8601DateFormatter.h"
#import "NightScoutUploader.h"
#import "Config.h"

#import "MainAppViewController.h"

@interface MainAppViewController () <RileyLinkDelegate> {
  NSDictionary *lastStatus;
}

@property (strong, nonatomic) RileyLink *rileyLink;
@property (strong, nonatomic) ISO8601DateFormatter *dateFormatter;
@property (strong, nonatomic) NSTimeZone *utcTimeZone;
@property (strong, nonatomic) NightScoutUploader *uploader;


@end

@implementation MainAppViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _rileyLink = [[RileyLink alloc] init];
  _rileyLink.channel = 2;
  _rileyLink.delegate = self;
  
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
  [self glucoseLink:nil didReceivePacket:packet];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [_rileyLink stop];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GlucoseLinkDelegate methods

- (void)glucoseLink:(RileyLink *)glucoseLink didReceivePacket:(MinimedPacket*)packet {
  [self.uploader addPacket:packet];
}

- (void)glucoseLink:(RileyLink *)glucoseLink updatedStatus:(NSDictionary*)status {
  lastStatus = status;
  // TODO: find place to display, now that we're using nightscout
}



@end
