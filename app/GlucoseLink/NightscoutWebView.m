//
//  NightscoutWebView.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/31/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import "NightscoutWebView.h"
#import "UIAlertView+Blocks.h"
#import "SWRevealViewController.h"
#import "Config.h"
#import "ConfigureViewController.h"

@interface NightscoutWebView () <UIWebViewDelegate> {
  IBOutlet UIBarButtonItem *menuButton;
}

@end

@implementation NightscoutWebView

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if (self.revealViewController != nil) {
    menuButton.target = self.revealViewController;
    [menuButton setAction:@selector(revealToggle:)];
    [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    self.revealViewController.rearViewRevealWidth = 162;
    
    if (![[Config sharedInstance]  hasValidConfiguration]) {
      UINavigationController *configNav = [self.storyboard instantiateViewControllerWithIdentifier:@"configuration"];
      ConfigureViewController *configViewController = [configNav viewControllers][0];
      [configViewController doInitialConfiguration];
      [self.revealViewController setFrontViewController:configNav];
    }
  }
  
  [self loadPage];
}

- (void)loadPage {
  NSURL *url = [NSURL URLWithString:[[Config sharedInstance] nightscoutURL]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [_webView loadRequest:request];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  [UIAlertView showWithTitle:@"Network Error"
                     message:[error localizedDescription]
           cancelButtonTitle:@"OK"
           otherButtonTitles:@[@"Retry"]
                    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                      if (buttonIndex == 1) {
                        [self loadPage];
                      }
                      NSLog(@"Retrying");
                    }];
}

@end
