//
//  ViewController.h
//  DashCamera
//
//  Created by WangYing on 23/12/2017.
//  Copyright © 2017 WAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LLSimpleCamera.h"

@class GADBannerView;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *landscapeView;
@property (weak, nonatomic) IBOutlet UIView *portraitView;


@property (weak, nonatomic) IBOutlet UIButton *btnMic;
@property (weak, nonatomic) IBOutlet UIButton *btnRotateCamera;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (weak, nonatomic) IBOutlet UIView *adsBannerView;

@property (weak, nonatomic) IBOutlet UIView *vwRecTime;
@property (weak, nonatomic) IBOutlet UIView *vwTraffic;

@property (weak, nonatomic) IBOutlet UILabel *lblRecordTime;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeed;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;



@property (weak, nonatomic) IBOutlet UIView *pCameraView;
@property (weak, nonatomic) IBOutlet UIView *pAdsView;
@property (weak, nonatomic) IBOutlet UIView *pOperationBar;
@property (weak, nonatomic) IBOutlet UILabel *pLblStatus;
@property (weak, nonatomic) IBOutlet UIButton *pBtnMute;
@property (weak, nonatomic) IBOutlet UIButton *pRotateCamera;
@property (weak, nonatomic) IBOutlet UIProgressView *pProgressView;
@property (weak, nonatomic) IBOutlet UIView *pSpeedView;
@property (weak, nonatomic) IBOutlet UIView *pRecTimeView;
@property (weak, nonatomic) IBOutlet UILabel *pLblRecTime;
@property (weak, nonatomic) IBOutlet UILabel *pLblSpeed;
@property (weak, nonatomic) IBOutlet UIButton *pBtnRecord;
@property (weak, nonatomic) IBOutlet UIButton *pBtnMenu;
@property (weak, nonatomic) IBOutlet UIButton *pBtnSave;


- (IBAction)onShowSettings:(id)sender;

@end

