//
//  ViewController.m
//  DashCamera
//
//  Created by WangYing on 23/12/2017.
//  Copyright © 2017 WAC. All rights reserved.
//

#import "ViewController.h"
#import "CameraAndPhoto.h"
#import "SettingsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@import GoogleMobileAds;

@interface ViewController () <UINavigationControllerDelegate, GADBannerViewDelegate>
{
    NSTimer *videoTimer;
    NSTimer *recordTimer;
    NSInteger recordSeconds;
    
    NSUInteger totalDiskSize;
    NSUInteger freeDiskSize;
}

@property (strong, nonatomic) LLSimpleCamera *camera;

@property (strong, nonatomic) UIImagePickerController *pickerController;
@property (assign, nonatomic) BOOL front;
@property (assign, nonatomic) BOOL noSound;
@property (assign, nonatomic) BOOL captureVideo;
@property (weak, nonatomic) IBOutlet UIView *operationBgView;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self initButtons];
    [self initAds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialize
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh position:LLCameraPositionRear videoEnabled:YES];
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    self.camera.fixOrientationAfterCapture = NO;
    
    [self.view bringSubviewToFront:self.operationBgView];
    [self.view bringSubviewToFront:self.btnMic];
    [self.view bringSubviewToFront:self.btnRotateCamera];
    [self.view bringSubviewToFront:self.btnMenu];
    [self.view bringSubviewToFront:self.btnRecord];
    [self.view bringSubviewToFront:self.btnSave];
    [self.view bringSubviewToFront:self.adsBannerView];
    [self.view bringSubviewToFront:self.vwRecTime];
    [self.view bringSubviewToFront:self.vwTraffic];
    [self.view bringSubviewToFront:self.lblStatus];
    [self.view bringSubviewToFront:self.progressView];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self.lblRecordTime setText:@"00:00"];
    recordSeconds = 0;
    self.noSound = YES;
    [self.camera setAudioEnabled:self.noSound];
    
    totalDiskSize = [self getTotalDiskSize];
    [self refreshStorageBar];
}

- (void)initButtons
{
    UIImage *imgMicOn = [UIImage imageNamed:@"res_btn_mic_on"];
    UIImage *imgMicOff = [UIImage imageNamed:@"res_btn_mic_off"];
    [self.btnMic setImage:imgMicOn forState:UIControlStateNormal];
    [self.btnMic setImage:imgMicOff forState:UIControlStateSelected];
    
    UIImage *imgRecordOn = [UIImage imageNamed:@"res_btn_record"];
    UIImage *imgRecordOff = [UIImage imageNamed:@"res_btn_recording"];
    [self.btnRecord setImage:imgRecordOn forState:UIControlStateNormal];
    [self.btnRecord setImage:imgRecordOff forState:UIControlStateSelected];
}

- (void)initAds
{
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.bannerView.adUnitID = @"ca-app-pub-6714239015427657/9815626562";
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    [self.adsBannerView addSubview:self.bannerView];
    self.adsBannerView = self.bannerView;
    
    [self.view bringSubviewToFront:self.adsBannerView];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    bannerView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        bannerView.alpha = 1;
    }];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
}

//function to hide the status bar, need to add key in Info.plist
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [self.camera start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)triggerMic:(id)sender {
    self.btnMic.selected = !self.btnMic.selected;
    self.noSound = !self.noSound;
    [self.camera setAudioEnabled:self.noSound];
}

- (IBAction)triggerRotateCamera:(id)sender {
    _front = !_front;
    [self.camera togglePosition];
}

- (IBAction)openMenu:(id)sender {
}

- (IBAction)triggerRecord:(id)sender {
    self.btnRecord.selected = !self.btnRecord.selected;
    
    self.captureVideo = !self.captureVideo;
    if (self.captureVideo) {
        videoTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                      target:self
                                                    selector:@selector(nextVideo)
                                                    userInfo:nil
                                                     repeats:YES];
        recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(countRecord)
                                                     userInfo:nil
                                                      repeats:YES];

        self.btnRotateCamera.hidden = YES;
        self.btnMic.hidden = YES;
        
        NSString *videoName = [self.dateFormatter stringFromDate:[NSDate date]];
        NSURL *outputURL = [[[self applicationDocumentsDirectory]
                             URLByAppendingPathComponent:videoName] URLByAppendingPathExtension:@"mp4"];
        [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
            [self.lblRecordTime setText:@"00:00"];
            recordSeconds = 0;
        }];
    } else {
        if (videoTimer)
            [videoTimer invalidate];
        if (recordTimer)
            [recordTimer invalidate];

        self.btnRotateCamera.hidden = NO;
        self.btnMic.hidden = NO;

        [self.camera stopRecording];
    }
}

- (IBAction)saveVideo:(id)sender {
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)nextVideo
{
    [self.lblRecordTime setText:@"00:00"];
    [self.camera stopRecording];
    recordSeconds = 0;
}

- (void)countRecord
{
    recordSeconds ++;
    int minute = floor(recordSeconds / 60.0);
    int second = (int)recordSeconds - minute * 60;

    NSString *strMinute = [NSString stringWithFormat:@"%i", minute];
    if ([strMinute length] == 1)
        strMinute = [@"0" stringByAppendingString:strMinute];

    NSString *strSecond = [NSString stringWithFormat:@"%i", second];
    if ([strSecond length] == 1)
        strSecond = [@"0" stringByAppendingString:strSecond];

    NSString *strRecordTime = [strMinute stringByAppendingString:[@":" stringByAppendingString:strSecond]];
    [self.lblRecordTime setText:strRecordTime];
    [self refreshStorageBar];
}

- (IBAction)onShowSettings:(id)sender {
    SettingsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (NSUInteger)getFreeDiskSize {
    NSDictionary *atDict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error:nil];
    NSUInteger freeSpace = [[atDict objectForKey:NSFileSystemFreeSize] unsignedIntegerValue];
    return freeSpace;
}

- (NSUInteger)getTotalDiskSize {
    NSDictionary *atDict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error:nil];
    NSUInteger totalSpace = [[atDict objectForKey:NSFileSystemSize] unsignedIntegerValue];
    return totalSpace;
}

- (void)refreshStorageBar {
    NSInteger total = totalDiskSize;
    freeDiskSize = [self getFreeDiskSize];
    NSInteger used = totalDiskSize - freeDiskSize;
    
    float totalSize = (total / 1024.0f) / 1024;
    float freeSize = (freeDiskSize / 1024.0f) / 1024;
    float usedSize = (used / 1024.0f) / 1024;
    
    float progress = usedSize / totalSize;
    [self.progressView setProgress:progress];
    
    NSString *strTotal = @"";
    NSString *strUnit = @"MB,  ";
    if (totalSize >= 1024) {
        strUnit = @"GB,  ";
        totalSize = totalSize / 1024;
    }
    strTotal = [NSString stringWithFormat:@"Total : %.1f", totalSize];
    strTotal = [strTotal stringByAppendingString:strUnit];
    
    NSString *strUsed = @"";
    strUnit = @"MB,  ";
    if (usedSize >= 1024) {
        strUnit = @"GB,  ";
        usedSize = usedSize / 1024;
    }
    strUsed = [NSString stringWithFormat:@"Used : %.1f", usedSize];
    strUsed = [strUsed stringByAppendingString:strUnit];
    
    NSString *strFree = @"";
    strUnit = @"MB";
    if (freeSize >= 1024) {
        strUnit = @"GB";
        freeSize = freeSize / 1024;
    }
    strFree = [NSString stringWithFormat:@"Free : %.1f", freeSize];
    strFree = [strFree stringByAppendingString:strUnit];
    
    NSString *status = [[strTotal stringByAppendingString:strUsed] stringByAppendingString:strFree];
    [self.lblStatus setText:status];
}

@end
