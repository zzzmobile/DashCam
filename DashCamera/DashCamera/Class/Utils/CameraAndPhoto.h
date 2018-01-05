//
//  CameraAndPhoto.h
//  Camera
//
//  Created by Wang Ying on 2/11/2017.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CameraAndPhoto : NSObject

+ (UIImagePickerController *)getCameraPickerControllerIsFront:(BOOL)isFront;

+ (UIImagePickerController *)getPhotoLibraryPickerController;

+ (UIImage *)getScreenShotWithView:(UIView *)view isFullSize:(BOOL)isFullSize;

+ (UIImage *)getImageFromImage:(UIImage*) superImage subImageSize:(CGSize)subImageSize subImageRect:(CGRect)subImageRect;

@end
