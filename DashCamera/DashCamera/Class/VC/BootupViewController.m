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


@interface BootupViewController ()
{
    NSInteger counter;
}

@end


@implementation BootupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    counter = 30;
    if (![AppSetting isSetted]) {
        [AppSetting initSetting];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:30.0
                                         target:self
                                       selector:@selector(showMainScreen)
                                       userInfo:nil
                                        repeats:NO];

        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(downCount)
                                       userInfo:nil
                                        repeats:YES];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (IBAction)onClickStart:(id)sender {
    [self showMainScreen];
}

- (void)showMainScreen
{
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)downCount
{
    if (counter == 0) {
        return;
    }

    counter --;
    [self.lblCounter setText:[NSString stringWithFormat:@"%li", counter]];
}

@end
