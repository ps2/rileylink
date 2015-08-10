//
//  PumpChatViewController.m
//  RileyLink
//
//  Created by Pete Schwamb on 8/8/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "PumpChatViewController.h"
#import "MinimedPacket.h"
#import "NSData+Conversion.h"
#import "Config.h"

@interface PumpChatViewController () {
  IBOutlet UILabel *resultsLabel;
}

@end

@implementation PumpChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)queryPumpButtonPressed:(id)sender {
  [self queryPumpForVersion];
}

- (void)queryPumpForVersion {
  resultsLabel.text = @"Sending wakeup packets...";
  
  NSString *pumpId = [[Config sharedInstance] pumpID];
  
  NSString *packetStr = [@"a7" stringByAppendingFormat:@"%@5D00", pumpId];
  NSData *data = [NSData dataWithHexadecimalString:packetStr];
  [_device sendPacketData:[MinimedPacket encodeData:data] withCount:90 andTimeBetweenPackets:0.078];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
