//
//  TestPacketSenderViewController.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/31/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "TestPacketSenderViewController.h"
#import "MinimedPacket.h"
#import "NSData+Conversion.h"

@interface TestPacketSenderViewController () {
  int testPacketNum;
  IBOutlet UILabel *testPacketNumberLabel;
}


@end

@implementation TestPacketSenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendPacketButtonPressed:(id)sender {
  NSData *bgPacket = [NSData dataWithHexadecimalString:@"614C05E0"];
  MinimedPacket *packet = [[MinimedPacket alloc] initWithData:bgPacket];
  [_device sendPacketData:packet.encodedRFData];
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
