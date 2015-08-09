//
//  ConfigureViewController.m
//  RileyLink
//
//  Created by Pete Schwamb on 6/26/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "ConfigureViewController.h"
#import "Config.h"
#import "UIAlertView+Blocks.h"
#import "SWRevealViewController.h"


@interface ConfigureViewController () {

  IBOutlet UITextField *nightscoutURL;
  IBOutlet UITextField *nightscoutAPISecret;
  IBOutlet UITextField *pumpId;
  IBOutlet UIBarButtonItem *menuButton;
  BOOL initialConfig;
  IBOutlet UIButton *continueButton;
}

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  if (self.revealViewController != nil) {
    menuButton.target = self.revealViewController;
    [menuButton setAction:@selector(revealToggle:)];
    [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
  }
  
  if (initialConfig && self.navigationItem != NULL) {
    self.navigationItem.leftBarButtonItem = NULL;
  } else {
    [continueButton setHidden:YES];
  }
}

- (IBAction)continuePressed:(id)sender {
  if ([self validateValues]) {
    // TODO: next step would be to connect rileylink
    UINavigationController *nightscoutNav = [self.storyboard instantiateViewControllerWithIdentifier:@"nightscout"];
    [self.revealViewController setFrontViewController:nightscoutNav animated:YES];
  } else {
    [UIAlertView showWithTitle:@"Invalid Configuration"
                       message:@"Please set valid values for Nightscout URL and Nightscout API Secret."
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil
            tapBlock:nil];

  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doInitialConfiguration {
  initialConfig = YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  
}

- (void)viewWillDisappear:(BOOL)animated {
  [self saveValues];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self loadValues];
}

- (void) loadValues {
  nightscoutURL.text = [[Config sharedInstance] nightscoutURL];
  nightscoutAPISecret.text = [[Config sharedInstance] nightscoutAPISecret];
  pumpId.text = [[Config sharedInstance] pumpID];
}

- (void) saveValues {
  [[Config sharedInstance] setNightscoutURL: nightscoutURL.text];
  [[Config sharedInstance] setNightscoutAPISecret: nightscoutAPISecret.text];
  [[Config sharedInstance] setPumpID:pumpId.text];
}

- (BOOL) validateValues {
  return ![nightscoutURL.text isEqualToString:@""] && ![nightscoutAPISecret.text isEqualToString:@""];
}

@end
