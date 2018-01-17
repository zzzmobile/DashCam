//
//  VideoTableRecord.m
//  DashCamera
//
//  Created by WangYing on 17/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "VideoTableRecord.h"

@implementation VideoTableRecord

    - (void)initRecord {
        self.videoName = @"";
        self.sLatitude = 0.0;
        self.sLongitude = 0.0;
        self.eLatitude = 0.0;
        self.eLongitude = 0.0;
    }
    
    - (void)setValuesName:(NSString*)name sLat:(NSInteger)slat sLon:(NSInteger)slon eLat:(NSInteger)elat eLon:(NSInteger)elon {
        self.videoName = name;
        self.sLatitude = slat / 1000000.0;
        self.sLongitude = slon / 1000000.0;
        self.eLatitude = elat / 1000000.0;
        self.eLongitude = elon / 1000000.0;
    }
    
    - (NSString*)getStartLocation {
        NSString *startLat = [self getLocationString:self.sLatitude];
        NSString *startLon = [self getLocationString:self.sLongitude];

        return [startLat stringByAppendingString:[@" N, " stringByAppendingString:[startLon stringByAppendingString:@" W"]]];
    }

    - (NSString*)getEndLocation {
        NSString *endLat = [self getLocationString:self.sLatitude];
        NSString *endLon = [self getLocationString:self.sLongitude];
        
        return [endLat stringByAppendingString:[@" N, " stringByAppendingString:[endLon stringByAppendingString:@" W"]]];
    }
    
    - (NSString*)getLocationString:(double)location {
        int degree = (int)location;
        double dblMinute = location - degree;
        int minute = (int)(dblMinute * 60);
        double second = ((dblMinute * 60) - minute) * 60;
        NSString *sDegree = [NSString stringWithFormat:@"%i° ", degree];
        NSString *sMinute = [NSString stringWithFormat:@"%02d′ ", minute];
        NSString *sSecond = [NSString stringWithFormat:@"%02.1f”", second];
        
        return [sDegree stringByAppendingString:[sMinute stringByAppendingString:sSecond]];
    }
    
@end
