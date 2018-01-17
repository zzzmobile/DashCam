//
//  VideoListViewController.m
//  DashCamera
//
//  Created by WangYing on 08/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "VideoListViewController.h"
#import "VideoCell.h"
#import "Tools.h"
#import "VideoTableRecord.h"
#import "VideoViewController.h"
#import "DBManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <FMDB.h>

@interface VideoListViewController ()
{
    NSMutableArray *videoData;
    NSMutableArray *videoRecordArray;
    UIAlertController *alertController;
    UIAlertController *renameController;
    UIAlertController *confirmController;
    UIAlertController *dmsController;
    NSInteger currentIndex;
}

@property (nonatomic, strong) UILabel *titleView;

@end

@implementation VideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getVideoList];
    [self initialize];
}

- (void)initialize
{
    currentIndex = 0;

    self.titleView = [[UILabel alloc] init];
    [self setTitleLabel];
    
    [Tools addLeftNavBarButtonWithImage:@"back_button" title:nil forVC:self action:@selector(onBack)];
    self.navigationItem.rightBarButtonItem = nil;
    
    alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *viewAction = [UIAlertAction actionWithTitle:@"View" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self viewVideo];
    }];
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentViewController:renameController animated:YES completion:nil];
    }];
    UIAlertAction *infoAction = [UIAlertAction actionWithTitle:@"GPS Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showGPSInfo];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentViewController:confirmController animated:YES completion:nil];
    }];
    [alertController addAction:viewAction];
    [alertController addAction:renameAction];
    [alertController addAction:infoAction];
    [alertController addAction:deleteAction];
    
    confirmController = [UIAlertController alertControllerWithTitle:@"Delete File" message:@"Are you sure you want to delete this video?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelDeleteAct = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [confirmController dismissViewControllerAnimated:YES completion:nil];
    }];
    [confirmController addAction:cancelDeleteAct];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteVideo];
    }];
    [confirmController addAction:okayAction];
    
    renameController = [UIAlertController alertControllerWithTitle:@"Rename Video File" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelRenAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [renameController dismissViewControllerAnimated:YES completion:nil];
    }];
    __weak typeof(self) weakSelf = self;
    [renameController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Please input new video file name", @"RenameVideo");
        [textField addTarget:weakSelf action:@selector(renameTextFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self renameVideo];
    }];
    setAction.enabled = NO;
    [renameController addAction:cancelRenAction];
    [renameController addAction:setAction];

    // DMS controller
    dmsController = [UIAlertController alertControllerWithTitle:@"GPS Info" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeDmsAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [dmsController dismissViewControllerAnimated:YES completion:nil];
    }];
    [dmsController addAction:closeDmsAction];
}

- (void)getVideoList
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSArray* filePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:docDir error:nil];
    videoData = [NSMutableArray array];
    videoRecordArray = [NSMutableArray array];

    for (NSString* path in filePaths) {
        NSString *filePath = [docDir stringByAppendingString:@"/"];
        filePath = [filePath stringByAppendingString:path];

        if ([[filePath pathExtension] isEqualToString:@"mp4"]) {
            [videoData addObject:filePath];
            if ([DBManager instance].appDatabase != nil) {
                VideoTableRecord *record = [[DBManager instance] fetchVideoRecord:path];
                if (record == nil) {
                    record = [[VideoTableRecord alloc] init];
                    [record initRecord];
                }
                [videoRecordArray addObject:record];
            }
        }
    }
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
    return [videoData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
    // Configure the cell...
    [cell setVideoPath:[videoData objectAtIndex:indexPath.row]];
    [cell setup];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentIndex = indexPath.row;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)viewVideo
{
    NSURL *url = [NSURL fileURLWithPath:[videoData objectAtIndex:currentIndex]];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    [playerViewController setTitle:[[videoData objectAtIndex:currentIndex] lastPathComponent]];
    playerViewController.player = [AVPlayer playerWithURL:url];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:playerViewController];
    [self presentViewController:nav animated:YES completion:nil];
    [playerViewController.player play];
}
    
- (void)showGPSInfo
{
    VideoTableRecord *record = [videoRecordArray objectAtIndex:currentIndex];
    if (record != nil) {
        NSString *message = [[[[@"Start: " stringByAppendingString:[record getStartLocation]] stringByAppendingString:@"\n"] stringByAppendingString:@"Stop: "] stringByAppendingString:[record getEndLocation]];
        [dmsController setMessage:message];
    }
    [self presentViewController:dmsController animated:YES completion:nil];
}

- (void)deleteVideo
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [videoData objectAtIndex:currentIndex];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        [videoData removeObjectAtIndex:currentIndex];
        VideoTableRecord *record = [videoRecordArray objectAtIndex:currentIndex];
        [[DBManager instance] deleteVideoRecord:record.videoName];
        [videoRecordArray removeObjectAtIndex:currentIndex];
        currentIndex = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self setTitleLabel];
        });
        
    } else {
        NSLog(@"Could not delete file -:%@ ", [error localizedDescription]);
    }
}

- (void)renameVideo {
    UITextField *txtName = renameController.textFields.firstObject;
    NSString *selFilePath = [videoData objectAtIndex:currentIndex];
    NSString *fileName = txtName.text;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSString *fullName = [[[docDir stringByAppendingString:@"/"] stringByAppendingString:fileName] stringByAppendingString:@".mp4"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:selFilePath toPath:fullName error:&error];
    [videoData setObject:fullName atIndexedSubscript:currentIndex];
    VideoTableRecord *record = [videoRecordArray objectAtIndex:currentIndex];
    NSString *oldName = record.videoName;
    record.videoName = fileName;
    [videoRecordArray setObject:record atIndexedSubscript:currentIndex];
    [[DBManager instance] updateVideoRecordName:oldName with:record.videoName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)setTitleLabel
{
    int count = (int)videoData.count;
    NSString *strCount = [NSString stringWithFormat:@"%i", count];
    self.titleView.text = [strCount stringByAppendingString:@" Videos"];
    self.titleView.backgroundColor = [UIColor clearColor];
    [self.titleView sizeToFit];
    self.navigationItem.titleView = self.titleView;
}

- (void)renameTextFieldDidChange {
    UITextField *txtFileName = renameController.textFields.firstObject;
    UIAlertAction *setAction = renameController.actions.lastObject;
    setAction.enabled = ([txtFileName.text length] >= 1);
}

@end
