//
//  ViewController.m
//  DashCamera
//
//  Created by WangYing on 23/12/2017.
//  Copyright © 2017 WAC. All rights reserved.
//

#import "ViewController.h"
#import "CameraAndPhoto.h"
#import "MenuViewController.h"
#import "AppSetting.h"
#import "DBManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>

@import GoogleMobileAds;

@interface ViewController () <UINavigationControllerDelegate, GADBannerViewDelegate, GADRewardBasedVideoAdDelegate, CLLocationManagerDelegate>
{
    NSTimer *videoTimer;
    NSTimer *recordTimer;
    NSTimer *saveAlertTimer;
    NSInteger recordSeconds;
    
    NSUInteger totalDiskSize;
    NSUInteger freeDiskSize;
    
    CLLocationManager *locManager;
    CLLocation *userLoc;
    CLHeading *userHeading;
    CLLocationSpeed carSpeed;
    
    UIAlertController *saveAlert;
    
    NSString *curVideoName;
    NSInteger startLon;
    NSInteger startLat;
    
    FMDatabase *database;
}

@property (strong, nonatomic) LLSimpleCamera *camera;

@property (strong, nonatomic) UIImagePickerController *pickerController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL front;
@property (assign, nonatomic) BOOL noSound;
@property (assign, nonatomic) BOOL captureVideo;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) GADBannerView *pBannerView;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation ViewController

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
        
        saveAlert = [UIAlertController alertControllerWithTitle:@"Message" message:@"Loop saved recording new loop" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [saveAlert dismissViewControllerAnimated:YES completion:^{
                [self closeSaveVideoAlert];
            }];
        }];
        [saveAlert addAction:action];
        
        [self initGoogleAdsVideo];
        [self initialize];
        [self initButtons];
        [self initAds];
        [self initLocationManager];
        [self rotateView];
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

        [self.view bringSubviewToFront:self.landscapeView];
        [self.view bringSubviewToFront:self.portraitView];

        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        [self.lblRecordTime setText:@"00:00"];
        recordSeconds = 0;
        self.noSound = YES;
        [self.camera setAudioEnabled:self.noSound];
        
        totalDiskSize = [self getTotalDiskSize];
        [self refreshStorageBar];
    }

    - (void)rotateView {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat w = screenRect.size.width;
        CGFloat h = screenRect.size.height;

        if (orientation == UIInterfaceOrientationPortrait) {
            self.portraitView.hidden = NO;
            self.landscapeView.hidden = YES;
            CGRect rect = screenRect;
            if (w > h) {
                rect.size.width = h;
                rect.size.height = w;
            }
            [self.camera.view setFrame:rect];

        } else {
            self.portraitView.hidden = YES;
            self.landscapeView.hidden = NO;
            CGRect rect = screenRect;
            if (w < h) {
                rect.size.width = h;
                rect.size.height = w;
            }
            [self.camera.view setFrame:rect];
        }
    }

    - (void)initButtons
    {
        UIImage *imgMicOn = [UIImage imageNamed:@"res_btn_mic_on"];
        UIImage *imgMicOff = [UIImage imageNamed:@"res_btn_mic_off"];
        [self.btnMic setImage:imgMicOn forState:UIControlStateNormal];
        [self.btnMic setImage:imgMicOff forState:UIControlStateSelected];
        [self.pBtnMute setImage:imgMicOn forState:UIControlStateNormal];
        [self.pBtnMute setImage:imgMicOff forState:UIControlStateSelected];

        UIImage *imgRecordOn = [UIImage imageNamed:@"res_btn_record"];
        UIImage *imgRecordOff = [UIImage imageNamed:@"res_btn_recording"];
        [self.btnRecord setImage:imgRecordOn forState:UIControlStateNormal];
        [self.btnRecord setImage:imgRecordOff forState:UIControlStateSelected];
        [self.pBtnRecord setImage:imgRecordOn forState:UIControlStateNormal];
        [self.pBtnRecord setImage:imgRecordOff forState:UIControlStateSelected];
        
        self.btnSave.enabled = NO;
        self.pBtnSave.enabled = NO;
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

        self.pBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        self.pBannerView.adUnitID = @"ca-app-pub-6714239015427657/9815626562";
        self.pBannerView.rootViewController = self;
        self.pBannerView.delegate = self;
        [self.pBannerView loadRequest:[GADRequest request]];
        
        [self.pAdsView addSubview:self.pBannerView];
        self.pAdsView = self.pBannerView;

    }

    - (void)initLocationManager
    {
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate = self;
        locManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locManager startUpdatingLocation];
        [locManager startUpdatingHeading];
    }

    - (void)initGoogleAdsVideo
    {
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
        if (![[GADRewardBasedVideoAd sharedInstance] isReady]) {
            GADRequest *request = [GADRequest request];
            [[GADRewardBasedVideoAd sharedInstance] loadRequest:request withAdUnitID:@"ca-app-pub-6714239015427657/7871989509"];
        }
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
        [self initialize];
    //    [self rotateView];
        [self.camera start];
        [self showGoogleVideo];
    }

    - (void)viewWillDisappear:(BOOL)animated
    {
        self.navigationController.navigationBarHidden = NO;
    }

    - (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
    {
        userLoc = [locations firstObject];
        if (userLoc != nil) {
            carSpeed = userLoc.speed;
            [self refreshTrafficData];
        }
    }

    - (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
    {
        userHeading = newHeading;
        if (userHeading != nil) {
            [self refreshTrafficData];
        }
    }

    - (BOOL)shouldAutorotate
    {
        [super shouldAutorotate];
        [self rotateView];
        return YES;
    }

    //- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    //    return UIInterfaceOrientationLandscapeRight;
    //}

    - (IBAction)triggerMic:(id)sender {
        [self muteSound];
    }

    - (IBAction)triggerMicPortrait:(id)sender {
        [self muteSound];
    }

    - (void)muteSound {
        self.btnMic.selected = !self.btnMic.selected;
        self.pBtnMute.selected = !self.pBtnMute.selected;
        self.noSound = !self.noSound;
        [self.camera setAudioEnabled:self.noSound];
    }

    - (IBAction)triggerRotateCamera:(id)sender {
        [self rotateCamera];
    }

    - (IBAction)triggerRotateCameraPortrait:(id)sender {
        [self rotateCamera];
    }

    - (void)rotateCamera {
        _front = !_front;
        [self.camera togglePosition];
    }

    - (IBAction)triggerRecord:(id)sender {
        [self recordVideo];
    }

    - (IBAction)triggerRecordPortrait:(id)sender {
        [self recordVideo];
    }


    - (void)recordVideo {
        self.btnRecord.selected = !self.btnRecord.selected;
        self.pBtnRecord.selected = !self.pBtnRecord.selected;
        
        self.captureVideo = !self.captureVideo;
        if (self.captureVideo) {
            [self startVideoRecord];
        } else {
            [self stopVideoRecord];
        }
    }

    - (void)startVideoRecord {
        NSInteger loopTime = [AppSetting getRecordLoopTime];
        videoTimer = [NSTimer scheduledTimerWithTimeInterval:loopTime
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
        self.pRotateCamera.hidden = YES;
        self.pBtnMute.hidden = YES;
        self.btnMic.hidden = YES;
        self.btnMenu.enabled = NO;
        self.btnSave.enabled = YES;
        self.pBtnMenu.enabled = NO;
        self.pBtnSave.enabled = YES;
        
        curVideoName = [self.dateFormatter stringFromDate:[NSDate date]];
        NSURL *outputURL = [[[self applicationDocumentsDirectory]
                             URLByAppendingPathComponent:curVideoName] URLByAppendingPathExtension:@"mp4"];
        [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
            [self.lblRecordTime setText:@"00:00"];
            recordSeconds = 0;
        }];

        startLat = (NSInteger)(userLoc.coordinate.latitude * 1000000);
        startLon = (NSInteger)(userLoc.coordinate.longitude * 1000000);
    }

    - (void)stopVideoRecord {
        if (videoTimer)
            [videoTimer invalidate];
        if (recordTimer)
            [recordTimer invalidate];
        
        self.btnRotateCamera.hidden = NO;
        self.pRotateCamera.hidden = NO;
        self.btnMic.hidden = NO;
        self.pBtnMute.hidden = NO;
        self.btnMenu.enabled = YES;
        self.btnSave.enabled = NO;
        self.pBtnMenu.enabled = YES;
        self.pBtnSave.enabled = NO;
        
        [self.lblRecordTime setText:@"00:00"];
        [self.pLblRecTime setText:@"00:00"];
        recordSeconds = 0;
        
        [self.camera stopRecording];
        
        NSInteger curLat = (NSInteger)(userLoc.coordinate.latitude * 1000000);
        NSInteger curLon = (NSInteger)(userLoc.coordinate.longitude * 1000000);
        
        // insert video's record to database
        [[DBManager instance] insertVideoRecord:[curVideoName stringByAppendingString:@".mp4"] sLat:startLat sLon:startLon eLat:curLat eLon:curLon];
    }

    - (IBAction)saveVideo:(id)sender {
        [self presentViewController:saveAlert animated:YES completion:nil];
        saveAlertTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self
                                                    selector:@selector(closeSaveVideoAlert)
                                                    userInfo:nil
                                                     repeats:YES];
        [self stopVideoRecord];
    }

    - (void)closeSaveVideoAlert {
        [saveAlert dismissViewControllerAnimated:YES completion:nil];
        [saveAlertTimer invalidate];
        [self startVideoRecord];
    }


    - (NSURL *)applicationDocumentsDirectory
    {
        return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    }

    - (void)nextVideo
    {
        [self.lblRecordTime setText:@"00:00"];
        [self.pLblRecTime setText:@"00:00"];
        if (videoTimer)
            [videoTimer invalidate];
        if (recordTimer)
            [recordTimer invalidate];
        [self.camera stopRecording];
        recordSeconds = 0;
        
        if (self.captureVideo) {
            [self startVideoRecord];
        } else {
            [self stopVideoRecord];
        }
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
        [self.pLblRecTime setText:strRecordTime];
        [self refreshStorageBar];
    }

    - (void)refreshTrafficData
    {
        NSString *strSpeed = @"";
        NSInteger speedUnit = [AppSetting getSpeedUnit];
        if (speedUnit == MeterPerHour) {
            int mph = (int)(carSpeed / 3600);
            strSpeed = [NSString stringWithFormat:@"%i MPH", mph];
        } else {
            int kph = (int)(carSpeed / (3600 * 1000));
            strSpeed = [NSString stringWithFormat:@"%i KPH", kph];
        }

        [self.lblSpeed setText:strSpeed];
        [self.pLblSpeed setText:strSpeed];
    }

    - (void)showGoogleVideo
    {
        if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
            [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
        }
    }

    - (IBAction)onShowSettings:(id)sender {
        if (self.captureVideo)
            return;
        
        MenuViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MenuViewController"];
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
        [self.pProgressView setProgress:progress];

        int minutes = (int)(freeSize / 2) / 60;
        NSString *strMinutes = [NSString stringWithFormat:@"(%i minutes)", minutes];
        NSString *strUnit = @"MB,  ";
        NSString *strFree = @"";
        strUnit = @"MB";
        if (freeSize >= 1024) {
            strUnit = @"GB";
            freeSize = freeSize / 1024;
        }
        strFree = [NSString stringWithFormat:@"Available : %.1f", freeSize];
        strFree = [strFree stringByAppendingString:strUnit];

        NSString *status = [strFree stringByAppendingString:strMinutes];
        [self.lblStatus setText:status];
        [self.pLblStatus setText:status];
    }


@end
