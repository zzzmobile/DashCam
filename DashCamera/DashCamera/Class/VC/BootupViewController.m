//
//  BootupViewController.m
//  DashCamera
//
//  Created by WangYing on 05/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "BootupViewController.h"
#import "../../ViewController.h"

@import GoogleMobileAds;

@interface BootupViewController () <GADRewardBasedVideoAdDelegate>
{
    
}

@end

UIAlertController *alertController;

@implementation BootupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *message = @"Obey all traffic laws when using this application. For your safety, to not operate this app while driving. Please make yoru adjustments while parked.";
    alertController = [UIAlertController alertControllerWithTitle:@"Message"
                                                               message:message
                                                        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okayButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(hideAlertController)
                                       userInfo:nil
                                        repeats:NO];
    });

    [self initGoogleAdsVideo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideAlertController
{
    [alertController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)startApp:(id)sender {
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
    }
}

- (void)initGoogleAdsVideo
{
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    if (![[GADRewardBasedVideoAd sharedInstance] isReady]) {
        GADRequest *request = [GADRequest request];
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:request withAdUnitID:@"ca-app-pub-6714239015427657/7871989509"];
    }
}

- (void)showMainScreen
{
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [self showMainScreen];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    [self showMainScreen];
}

@end
