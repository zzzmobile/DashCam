//
//  ViewController.m
//  DashCamera
//
//  Created by WangYing on 23/12/2017.
//  Copyright © 2017 WAC. All rights reserved.
//

#import "ViewController.h"
#import "CameraAndPhoto.h"


@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *pickerController;
@property (assign, nonatomic) BOOL front;
@property (weak, nonatomic) IBOutlet UIView *operationBgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    [self handleCamera];
    [self initButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)handleCamera
{
    double width = self.cameraView.bounds.size.width;
    double height = self.cameraView.bounds.size.height;
    CGFloat scale = width / height;
    self.pickerController.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
    [self.view addSubview:self.pickerController.view];
    [self.view bringSubviewToFront:self.operationBgView];
    [self.view bringSubviewToFront:self.btnMic];
    [self.view bringSubviewToFront:self.btnRotateCamera];
    [self.view bringSubviewToFront:self.btnMenu];
    [self.view bringSubviewToFront:self.btnRecord];
    [self.view bringSubviewToFront:self.btnSave];
    [self.view bringSubviewToFront:self.vwRecTime];
    [self.view bringSubviewToFront:self.vwTraffic];
    [self.view bringSubviewToFront:self.lblStatus];
    [self.view bringSubviewToFront:self.progressView];
}

//function to hide the status bar, need to add key in Info.plist
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput
didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer
previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer
     resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
      bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings
                error:(nullable NSError *)error
{   NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithData:imageData];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); NSLog(@"%s", __FUNCTION__);
}

#pragma mark -  setter getter

- (UIImagePickerController *)pickerController
{
    if (_pickerController == nil) {
        _pickerController = [CameraAndPhoto getCameraPickerControllerIsFront:_front];
        _pickerController.delegate = self;
        _pickerController.showsCameraControls = NO;
        _pickerController.navigationBarHidden = YES;
    }
    
    return _pickerController;
}

- (IBAction)triggerMic:(id)sender {
    self.btnMic.selected = !self.btnMic.selected;
}

- (IBAction)triggerRotateCamera:(id)sender {
    _front = !_front;
    if (_front) {
        self.pickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        self.pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

- (IBAction)openMenu:(id)sender {
}

- (IBAction)triggerRecord:(id)sender {
    self.btnRecord.selected = !self.btnRecord.selected;
}

- (IBAction)saveVideo:(id)sender {
}

@end
