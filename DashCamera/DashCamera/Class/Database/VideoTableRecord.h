//
//  VideoTableRecord.h
//  DashCamera
//
//  Created by WangYing on 17/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoTableRecord : NSObject
    
    @property (nonatomic, strong) NSString *videoName;
    @property (nonatomic) double sLatitude;
    @property (nonatomic) double sLongitude;
    @property (nonatomic) double eLatitude;
    @property (nonatomic) double eLongitude;
    
    - (void)initRecord;
    - (void)setValuesName:(NSString*)name sLat:(NSInteger)slat sLon:(NSInteger)slon eLat:(NSInteger)elat eLon:(NSInteger)elon;
    - (NSString*)getStartLocation;
    - (NSString*)getEndLocation;

@end
