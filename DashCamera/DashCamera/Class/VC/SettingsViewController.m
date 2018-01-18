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
#import "SettingValueCell.h"
#import "AppSetting.h"
#import "DBManager.h"

@import GoogleMobileAds;

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate>
{
    NSMutableArray *settingTableData;
    UIAlertController *alertUnitSpeed;
    UIAlertController *alertLoopTime;
    UIAlertController *alertAutoRecord;
    UIAlertController *alertAllDelete;
}

@property (nonatomic, strong) GADBannerView *bannerView;

@end

@implementation SettingsViewController

typedef NS_ENUM(NSInteger, SectionType)
{
    SectionType_UnitOfSpeed = 0,
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
    [self initAds];
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
    
    [self makeUnitofSpeedAlert];
    [self makeLoopTimeAlert];
    [self makeAutoRecordAlert];
    [self makeAllDeleteAlert];
}

- (void)initAds
{
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.bannerView.adUnitID = @"ca-app-pub-6714239015427657/9122272249";
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    [self.adsView addSubview:self.bannerView];
    self.adsView = self.bannerView;
    
    [self.view bringSubviewToFront:self.adsView];
}

- (void)makeUnitofSpeedAlert
{
    // Alert for Unit of Speed
    alertUnitSpeed = [UIAlertController alertControllerWithTitle:@"Unit of Speed" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertUnitSpeed dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *mphAction = [UIAlertAction actionWithTitle:@"Meter Per Hour(MPH)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AppSetting setSpeedUnit:MeterPerHour];
        [self.tblSetting reloadData];
    }];
    UIAlertAction *kphAction = [UIAlertAction actionWithTitle:@"Kilometer Per Hour(KPH)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AppSetting setSpeedUnit:KilometerPerHour];
        [self.tblSetting reloadData];
    }];
    
    [alertUnitSpeed addAction:mphAction];
    [alertUnitSpeed addAction:kphAction];
    [alertUnitSpeed addAction:cancelAction];
}

- (void)makeLoopTimeAlert
{
    // Alert for Loop Time
    alertLoopTime = [UIAlertController alertControllerWithTitle:@"Loop Time" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertLoopTime dismissViewControllerAnimated:YES completion:nil];
    }];
    __weak typeof(self) weakSelf = self;
    [alertLoopTime addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Please input only numbers(1~3600)", @"LoopTimePlaceholder");
        [textField addTarget:weakSelf action:@selector(loopTimeTextFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *txtSeconds = alertLoopTime.textFields.firstObject;
        NSInteger value = [txtSeconds.text integerValue];
        if (value > 3600)
            value = 3600;

        [AppSetting setRecordLoopTime:value];
        [self.tblSetting reloadData];
    }];
    setAction.enabled = NO;
    [alertLoopTime addAction:cancelAction];
    [alertLoopTime addAction:setAction];
}

- (void)makeAutoRecordAlert
{
    alertAutoRecord = [UIAlertController alertControllerWithTitle:@"Auto Record" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertAutoRecord dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AppSetting setAutoRecord:YES];
        [self.tblSetting reloadData];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AppSetting setAutoRecord:NO];
        [self.tblSetting reloadData];
    }];
    
    [alertAutoRecord addAction:cancelAction];
    [alertAutoRecord addAction:yesAction];
    [alertAutoRecord addAction:noAction];
}

- (void)makeAllDeleteAlert {
    alertAllDelete = [UIAlertController alertControllerWithTitle:@"Delete All Videos" message:@"Are you sure you want to delete all videos?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelDeleteAct = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertAllDelete dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertAllDelete addAction:cancelDeleteAct];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteAllVideos];
    }];
    [alertAllDelete addAction:okayAction];
}

- (void)initSettingTable
{
    settingTableData = [NSMutableArray array];
    [settingTableData addObject:@"Unit of Speed"];
    [settingTableData addObject:@"Loop Time(seconds)"];
    [settingTableData addObject:@"Auto Record (coming soon)"];
    [settingTableData addObject:@"Delete All Videos"];
    [settingTableData addObject:@"Advanced (coming soon)"];
    
    [self.tblSetting registerNib:[UINib nibWithNibName:@"SettingValueCell" bundle:nil] forCellReuseIdentifier:[SettingValueCell reuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
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
    NSString* cellTitle = [settingTableData objectAtIndex:indexPath.row];
    
    SettingValueCell* cell = (SettingValueCell*)[self.tblSetting dequeueReusableCellWithIdentifier:[SettingValueCell reuseIdentifier] forIndexPath:indexPath];
    [cell setCellTitle:cellTitle];

    if (indexPath.row == SectionType_UnitOfSpeed) {
        NSString* strValue = @"";
        if ([AppSetting getSpeedUnit] == MeterPerHour)
            strValue = @"(MPH)";
        else
            strValue = @"(KPH)";
        [cell setCellStringValue:strValue];
    } else if (indexPath.row == SectionType_LoopTime) {
        [cell setCellIntegerValue:[AppSetting getRecordLoopTime]];
    } else if (indexPath.row == SectionType_AutoRecord) {
        [cell setCellBoolValue:[AppSetting isAutoRecord]];
        [cell.tableCellName setTextColor:[UIColor grayColor]];
        cell.userInteractionEnabled = NO;
    } else if (indexPath.row == SectionType_DeleteAllVideos){
        [cell setCellStringValue:@""];
    } else {
        [cell setCellStringValue:@""];
        [cell.tableCellName setTextColor:[UIColor grayColor]];
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [settingTableData count];
}

#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == SectionType_UnitOfSpeed) {
        [self presentViewController:alertUnitSpeed animated:YES completion:nil];
    } else if (indexPath.row == SectionType_LoopTime) {
        [self presentViewController:alertLoopTime animated:YES completion:nil];
    } else if (indexPath.row == SectionType_AutoRecord) {
        [self presentViewController:alertAutoRecord animated:YES completion:nil];
    } else if (indexPath.row == SectionType_DeleteAllVideos) {
        [self presentViewController:alertAllDelete animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)loopTimeTextFieldDidChange
{
    UITextField *txtLoopTime = alertLoopTime.textFields.firstObject;
    UIAlertAction *setAction = alertLoopTime.actions.lastObject;
    NSInteger loopTime = [txtLoopTime.text integerValue];
    setAction.enabled = (loopTime >= 1);
}

- (void)deleteAllVideos {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSArray* filePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:docDir error:nil];

    for (NSString *path in filePaths) {
        NSError *error;
        NSString *fullPath = [[docDir stringByAppendingString:@"/"] stringByAppendingString:path];
        if ([[fullPath pathExtension] isEqualToString:@"mp4"])
            [fileManager removeItemAtPath:fullPath error:&error];
    }
    
    [[DBManager instance] clearVideoRecords];
}

@end
