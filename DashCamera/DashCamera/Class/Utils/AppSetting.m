//
//  AppSetting.m
//  DashCamera
//
//  Created by WangYing on 10/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "AppSetting.h"

#define DEFAULTS [NSUserDefaults standardUserDefaults]

static NSString* const settingSpeedUnitKey  = @"Setting_SpeedUnit";
static NSString* const settingLoopTimeKey  = @"Setting_LoopTime";
static NSString* const settingAutoRecordKey  = @"Setting_AutoRecord";
static NSString* const settingVideoSettingKey  = @"Setting_VideoSetting";

@implementation AppSetting

+ (void)initSetting
{
    [DEFAULTS setInteger:VideoQualityMedium forKey:settingVideoSettingKey];
    [DEFAULTS setInteger:MeterPerHour forKey:settingSpeedUnitKey];
    [DEFAULTS setInteger:600 forKey:settingLoopTimeKey];
    [DEFAULTS setBool:NO forKey:settingAutoRecordKey];
    [DEFAULTS synchronize];
}

+ (NSInteger)getSpeedUnit
{
    return [DEFAULTS integerForKey:settingSpeedUnitKey];
}

+ (void)setSpeedUnit:(NSInteger)unit
{
    [DEFAULTS setInteger:unit forKey:settingSpeedUnitKey];
    [DEFAULTS synchronize];
}

+ (NSInteger)getRecordLoopTime
{
    return [DEFAULTS integerForKey:settingLoopTimeKey];
}

+ (void)setRecordLoopTime:(NSInteger)seconds
{
    [DEFAULTS setInteger:seconds forKey:settingLoopTimeKey];
    [DEFAULTS synchronize];
}

+ (BOOL)isAutoRecord
{
    return [DEFAULTS boolForKey:settingAutoRecordKey];
}

+ (void)setAutoRecord:(BOOL)autoRecord
{
    [DEFAULTS setBool:autoRecord forKey:settingAutoRecordKey];
    [DEFAULTS synchronize];
}

+ (NSInteger)getVideoSetting
{
    return [DEFAULTS integerForKey:settingVideoSettingKey];
}

+ (void)setVideoSetting:(NSInteger)setting
{
    [DEFAULTS setInteger:setting forKey:settingVideoSettingKey];
    [DEFAULTS synchronize];
}


+ (BOOL)isSetted
{
    if ([DEFAULTS objectForKey:settingSpeedUnitKey] != nil)
        return YES;
    else
        return NO;
}

@end
