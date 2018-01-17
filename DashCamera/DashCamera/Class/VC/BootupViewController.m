//
//  BootupViewController.m
//  DashCamera
//
//  Created by WangYing on 05/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "BootupViewController.h"
#import "../../ViewController.h"
#import "AppSetting.h"

UIAlertController *alertController;

@implementation BootupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *message = @"Obey all traffic laws when using this application. For your safety, do not operate this app while driving. Please make yoru adjustments while parked.";
    alertController = [UIAlertController alertControllerWithTitle:@"Message"
                                                               message:message
                                                        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okayButton];

    if (![AppSetting isSetted]) {
        [AppSetting initSetting];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval:45.0
                                         target:self
                                       selector:@selector(hideAlertController)
                                       userInfo:nil
                                        repeats:NO];
    });
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
    [self showMainScreen];
}

- (IBAction)startApp:(id)sender {
    [self showMainScreen];
}

- (void)showMainScreen
{
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
    [self presentViewController:vc animated:NO completion:nil];
}

@end
