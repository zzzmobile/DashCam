//
//  DBManager.h
//  DashCamera
//
//  Created by WangYing on 17/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "VideoTableRecord.h"
#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface DBManager : NSObject
    
    @property (nonatomic, strong) FMDatabase *appDatabase;

    + (instancetype)instance;

    - (void)openDatabase;
    - (void)closeDatabase;
    
    - (NSInteger)fetchVideoRecordCound;
    - (VideoTableRecord*)fetchVideoRecord:(NSString*)videoName;
    - (BOOL)insertVideoRecord:(NSString*)videoName sLat:(NSInteger)slat sLon:(NSInteger)slon eLat:(NSInteger)elat eLon:(NSInteger)elon;
    - (BOOL)updateVideoRecordName:(NSString*)videoName with:(NSString*)newName;
    - (BOOL)deleteVideoRecord:(NSString*)videoName;
    - (BOOL)clearVideoRecords;

@end
