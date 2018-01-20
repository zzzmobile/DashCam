//
//  AppSetting.h
//  DashCamera
//
//  Created by WangYing on 10/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    // The default state has to be off
    MeterPerHour,
    KilometerPerHour
} AppSpeedUnit;

typedef enum: NSUInteger {
    VideoQualityHigh,
    VideoQualityMedium,
    VideoQualityLow
} AppVideoSetting;

@interface AppSetting : NSObject

+ (void)initSetting;
+ (NSInteger)getSpeedUnit;
+ (void)setSpeedUnit:(NSInteger)unit;
+ (NSInteger)getRecordLoopTime;
+ (void)setRecordLoopTime:(NSInteger)seconds;
+ (BOOL)isAutoRecord;
+ (void)setAutoRecord:(BOOL)autoRecord;
+ (NSInteger)getVideoSetting;
+ (void)setVideoSetting:(NSInteger)setting;

+ (BOOL)isSetted;

@end
