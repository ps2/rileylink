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
#import "RileyLinkBLEManager.h"

@interface PumpChatViewController () {
  IBOutlet UILabel *resultsLabel;
  IBOutlet UILabel *pumpIdLabel;
}

@end

@implementation PumpChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(packetReceived:)
                                               name:RILEY_LINK_EVENT_PACKET_RECEIVED
                                             object:self.device];
  
  pumpIdLabel.text = [NSString stringWithFormat:@"PumpID: %@", [[Config sharedInstance] pumpID]];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self];
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
  [_device sendPacketData:[MinimedPacket encodeData:data] withCount:100 andTimeBetweenPackets:0.078];
}

- (void)handlePacketFromPump:(MinimedPacket*)p {
  if (p.messageType == MESSAGE_TYPE_PUMP_STATUS_ACK) {
    resultsLabel.text = @"Pump acknowleged wakeup!";
    // Send query for pump model #
    NSString *packetStr = [@"a7" stringByAppendingFormat:@"%@8d00", [[Config sharedInstance] pumpID]];
    NSData *data = [NSData dataWithHexadecimalString:packetStr];
    [_device sendPacketData:[MinimedPacket encodeData:data]];
  } else if (p.messageType == MESSAGE_TYPE_GET_PUMP_MODEL) {
    //unsigned char len = [p.data bytes][6];
    NSString *version = [NSString stringWithCString:&[p.data bytes][7] encoding:NSASCIIStringEncoding];
    resultsLabel.text = [@"Pump Model: " stringByAppendingString:version];
    
  }
  
}


- (void)packetReceived:(NSNotification*)notification {
  if (notification.object == self.device) {
    MinimedPacket *packet = notification.userInfo[@"packet"];
    if (packet && [packet.address isEqualToString:[[Config sharedInstance] pumpID]]) {
      [self handlePacketFromPump:packet];
    }
  }
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
