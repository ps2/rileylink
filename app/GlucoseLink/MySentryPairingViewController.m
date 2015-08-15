//
//  MySentryPairingViewController.m
//  RileyLink
//
//  Created by Nathan Racklyeft on 8/14/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "MySentryPairingViewController.h"
#import "Config.h"
#import "NSData+Conversion.h"
#import "RileyLinkBLEManager.h"

typedef NS_ENUM(NSUInteger, PairingState) {
    PairingStateComplete,
    PairingStateNeedsConfig,
    PairingStateReady,
    PairingStateStarted,
    PairingStateReceivedFindPacket,
    PairingStateReceivedLinkPacket
};


@interface MySentryPairingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UITextField *deviceIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) UITapGestureRecognizer *flailGestureRecognizer;

@property (nonatomic) PairingState state;
@property (nonatomic) unsigned char sendCounter;

@end

@implementation MySentryPairingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sendCounter = 0;
    [self.device setTXChannel:3];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(packetReceived:)
                                                 name:RILEY_LINK_EVENT_PACKET_RECEIVED
                                               object:self.device];

    self.state = PairingStateNeedsConfig;

    self.deviceIDTextField.delegate = self;
    [self.view addGestureRecognizer:self.flailGestureRecognizer];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RILEY_LINK_EVENT_PACKET_RECEIVED
                                                  object:self.device];
}

- (UITapGestureRecognizer *)flailGestureRecognizer
{
    if (!_flailGestureRecognizer) {
        _flailGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
        _flailGestureRecognizer.cancelsTouchesInView = NO;
        _flailGestureRecognizer.enabled = NO;
    }
    return _flailGestureRecognizer;
}

- (void)setState:(PairingState)state {
    if (state == _state) {
        return;
    }

    _state = state;

    switch (state) {
        case PairingStateNeedsConfig:
            self.startButton.enabled = NO;

            self.instructionLabel.text = NSLocalizedString(@"Enter a 6-digit numeric value to identify your MySentry.",
                                                           @"Device ID instruction");
            break;
        case PairingStateReady:
            self.startButton.enabled = YES;
            self.progressView.progress = 0;

            self.instructionLabel.text = NSLocalizedString(@"Tap to begin.",
                                                           @"Start button instruction");
            break;
        case PairingStateStarted:
            self.startButton.enabled = NO;
            self.deviceIDTextField.enabled = NO;
            [self.progressView setProgress:1.0 / 4.0 animated:YES];

            self.instructionLabel.text = NSLocalizedString(@"On your pump, go to the Find Device screen and select \"Find Device\"."
                                                           @"\n"
                                                           @"\nMain Menu >"
                                                           @"\nUtilities >"
                                                           @"\nConnect Devices >"
                                                           @"\nOther Devices >"
                                                           @"\nOn >"
                                                           @"\nFind Device",
                                                           @"Pump find device instruction");
            break;
        case PairingStateReceivedFindPacket:
            [self.progressView setProgress:2.0 / 4.0 animated:YES];

            self.instructionLabel.text = NSLocalizedString(@"Pairing in process, please wait."
                                                           @"\nIt may take up to 2 minutes to complete.",
                                                           @"Pairing waiting instruction");
            break;
        case PairingStateReceivedLinkPacket:
            [self.progressView setProgress:3.0 / 4.0 animated:YES];
            break;
        case PairingStateComplete:
            [self.progressView setProgress:4.0 / 4.0 animated:YES];

            self.instructionLabel.text = NSLocalizedString(@"Congratulations! Pairing is complete.",
                                                           @"Pairing waiting instruction");
            break;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.flailGestureRecognizer.enabled = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.flailGestureRecognizer.enabled = NO;

    if (textField.text.length == 6) {
        self.state = PairingStateReady;
    } else if (PairingStateReady == self.state) {
        self.state = PairingStateNeedsConfig;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (newString.length > 6) {
        return NO;
    } else if (newString.length == 6) {
        textField.text = newString;
        [textField resignFirstResponder];
        return NO;
    } else if (PairingStateReady == self.state) {
        self.state = PairingStateNeedsConfig;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

#pragma mark - Actions

- (void)packetReceived:(NSNotification *)note {
    MinimedPacket *packet = note.userInfo[@"packet"];

    if (packet &&
        PACKET_TYPE_PUMP == packet.packetType &&
        [packet.address isEqualToString:[Config sharedInstance].pumpID])
    {
        [self sendReplyToPacket:packet];

        switch (packet.messageType) {
            case MESSAGE_TYPE_FIND_DEVICE:
                if (PairingStateStarted == self.state) {
                    self.state = PairingStateReceivedFindPacket;
                }
                break;
            case MESSAGE_TYPE_DEVICE_LINK:
                if (PairingStateReceivedFindPacket == self.state) {
                    self.state = PairingStateReceivedLinkPacket;
                }
            case MESSAGE_TYPE_PUMP_STATUS:
            case MESSAGE_TYPE_PUMP_BACKFILL:
                if (PairingStateReceivedLinkPacket == self.state) {
                    self.state = PairingStateComplete;
                }
            default:
                break;
        }
    }
}

- (void)sendReplyToPacket:(MinimedPacket *)packet
{
    NSString *replyString = [NSString stringWithFormat:@"%02x%@%02x%02x%@00%02x000000",
                             PACKET_TYPE_PUMP,
                             [Config sharedInstance].pumpID,
                             MESSAGE_TYPE_PUMP_STATUS_ACK,
                             self.sendCounter++,
                             self.deviceIDTextField.text,
                             packet.messageType
                             ];
    NSData *data = [NSData dataWithHexadecimalString:replyString];

    [self.device sendPacketData:[MinimedPacket encodeData:data]];
}

- (void)closeKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)startPairing:(id)sender {
    if (PairingStateReady == self.state) {
        self.state = PairingStateStarted;
    }
}

@end
