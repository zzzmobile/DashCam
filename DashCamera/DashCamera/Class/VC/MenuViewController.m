//
//  MenuViewController.m
//  DashCamera
//
//  Created by WangYing on 14/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "VideoListViewController.h"
#import "Tools.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

typedef NS_ENUM(NSInteger, SectionType)
{
    SectionType_Settings = 0,
    SectionType_SavedVideos,
    SectionType_Log
};

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialize
{
    UILabel *titleView = [[UILabel alloc] init];
    titleView.text = @"Menu";
    titleView.backgroundColor = [UIColor clearColor];
    [titleView sizeToFit];
    self.navigationItem.titleView = titleView;
    
    [Tools addLeftNavBarButtonWithImage:@"back_button" title:nil forVC:self action:@selector(onBack)];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)onBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuItemCell" forIndexPath:indexPath];
    NSString *title = @"";
    if (indexPath.row == SectionType_Settings)
        title = @"Settings";
    else if (indexPath.row == SectionType_SavedVideos)
        title = @"Saved Videos";
    else
        title = @"Log/History";

    UIFont *font = [UIFont systemFontOfSize:20];
    [cell.textLabel setFont:font];
    [cell.textLabel setText:title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == SectionType_Settings) {
        SettingsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    } else if (indexPath.row == SectionType_SavedVideos) {
        VideoListViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoListViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
