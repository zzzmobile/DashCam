//
//  SettingsViewController.m
//  DashCamera
//
//  Created by WangYing on 06/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingTableViewCell.h"
#import "VideoListViewController.h"
#import "Tools.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *settingTableData;
}

@end

@implementation SettingsViewController

typedef NS_ENUM(NSInteger, SectionType)
{
    SectionType_Videos = 0,
    SectionType_Log,
    SectionType_UnitOfSpeed,
    SectionType_LoopTime,
    SectionType_AutoRecord,
    SectionType_DeleteAllVideos,
    SectionType_Advanced
};

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSettingTable];
    [self initialize];
}

- (void)initialize
{
    UILabel *titleView = [[UILabel alloc] init];
    titleView.text = @"Settings";
    titleView.backgroundColor = [UIColor clearColor];
    [titleView sizeToFit];
    self.navigationItem.titleView = titleView;
    
    [Tools addLeftNavBarButtonWithImage:@"back_button" title:nil forVC:self action:@selector(onBack)];
    self.navigationItem.rightBarButtonItem = nil;
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

- (void)initSettingTable
{
    settingTableData = [NSMutableArray array];
    [settingTableData addObject:@"Videos"];
    [settingTableData addObject:@"Log"];
    [settingTableData addObject:@"Unit of Speed"];
    [settingTableData addObject:@"Loop Time(minutes)"];
    [settingTableData addObject:@"Auto Record"];
    [settingTableData addObject:@"Delete All Videos"];
    [settingTableData addObject:@"Advanced"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBack {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (IBAction)onSaveSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <UITableViewDataSource>
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SettingTableViewCell *cell = [self.tblSetting dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];

    NSString* cellTitle = [settingTableData objectAtIndex:indexPath.row];
    [cell setCellTitle:cellTitle];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [settingTableData count];
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == SectionType_Videos) {
        VideoListViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoListViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
