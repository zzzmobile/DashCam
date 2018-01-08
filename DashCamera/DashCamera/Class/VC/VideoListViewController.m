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
#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface VideoListViewController ()
{
    NSMutableArray *videoData;
    UIAlertController *alertController;
    UIAlertController *confirmController;
    NSInteger currentIndex;
}

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

    UILabel *titleView = [[UILabel alloc] init];
    NSString *strCount = [NSString stringWithFormat:@"%lu", videoData.count];
    titleView.text = [strCount stringByAppendingString:@" Videos"];
    titleView.backgroundColor = [UIColor clearColor];
    [titleView sizeToFit];
    self.navigationItem.titleView = titleView;
    
    [Tools addLeftNavBarButtonWithImage:@"back_button" title:nil forVC:self action:@selector(onBack)];
    self.navigationItem.rightBarButtonItem = nil;
    
    alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *viewAction = [UIAlertAction actionWithTitle:@"View Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self viewVideo];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentViewController:confirmController animated:YES completion:nil];
    }];
    [alertController addAction:viewAction];
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
}

- (void)getVideoList
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSArray* filePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:docDir error:nil];
    videoData = [NSMutableArray array];

    for (NSString* path in filePaths) {
        NSString *filePath = [docDir stringByAppendingString:@"/"];
        filePath = [filePath stringByAppendingString:path];
        [videoData addObject:filePath];
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
//    VideoViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VideoViewController"];
//    vc.videoPath = [videoData objectAtIndex:currentIndex];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:nav animated:YES completion:nil];
    
    NSURL *url = [NSURL fileURLWithPath:[videoData objectAtIndex:currentIndex]];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    [playerViewController setTitle:[[videoData objectAtIndex:currentIndex] lastPathComponent]];
    playerViewController.player = [AVPlayer playerWithURL:url];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:playerViewController];
    [self presentViewController:nav animated:YES completion:nil];
    [playerViewController.player play];
}

- (void)deleteVideo
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [videoData objectAtIndex:currentIndex];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        [videoData removeObjectAtIndex:currentIndex];
        currentIndex = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } else {
        NSLog(@"Could not delete file -:%@ ", [error localizedDescription]);
    }
}

@end
