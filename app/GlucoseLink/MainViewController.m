//
//  MainViewController.m
//  GlucoseLink
//
//  Created by Pete Schwamb on 7/31/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import "MainViewController.h"
#import "RileyLink.h"
#import "NSData+Conversion.h"
#import "PumpStatusMessage.h"
#import "ISO8601DateFormatter.h"
#import "UIAlertView+Blocks.h"
#import "NightScoutUploader.h"

// ********************************* Configuration ***************************
static NSString *nightScoutURL = @"";
static NSString *nightScoutAPISecret =  @"";
static NSString *pumpSerial = @"";

@interface MainViewController () <RileyLinkDelegate, UIWebViewDelegate> {
  NSDictionary *lastStatus;
}

@property (strong, nonatomic) RileyLink *rileyLink;
@property (strong, nonatomic) ISO8601DateFormatter *dateFormatter;
@property (strong, nonatomic) NSTimeZone *utcTimeZone;
@property (strong, nonatomic) NightScoutUploader *uploader;

@end

@implementation MainViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _rileyLink = [[RileyLink alloc] init];
  _rileyLink.channel = 2;
  _rileyLink.delegate = self;
  
  [self loadMainAppPage];
  
  _dateFormatter = [[ISO8601DateFormatter alloc] init];
  _dateFormatter.includeTime = YES;
  _dateFormatter.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
  
  self.uploader = [[NightScoutUploader alloc] init];
  self.uploader.endpoint = nightScoutURL;
  self.uploader.APISecret = nightScoutAPISecret;
  
  //[self.uploader test];
  [self performSelector:@selector(generateMockData) withObject:nil afterDelay:2];
}

- (void)loadMainAppPage {
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:nightScoutURL]];
  [_webView loadRequest:request];
}

- (void)viewDidDisappear:(BOOL)animated {
  [_rileyLink stop];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)generateMockData {
  NSData *bgPacket = [NSData dataWithHexadecimalString:@"0000a5c527ad00f111"];
  MinimedPacket *packet = [[MinimedPacket alloc] initWithData:bgPacket];
  packet.capturedAt = [NSDate date];
  [self glucoseLink:nil didReceivePacket:packet];
}

- (void)didReceiveMemoryWarning
{
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

#pragma mark UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  [UIAlertView showWithTitle:@"Network Error"
                     message:[error localizedDescription]
           cancelButtonTitle:@"Retry"
           otherButtonTitles:nil
                    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        [self loadMainAppPage];
                        NSLog(@"Retrying");
                    }];
}

@end
