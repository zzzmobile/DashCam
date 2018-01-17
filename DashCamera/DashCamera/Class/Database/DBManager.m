//
//  DBManager.m
//  DashCamera
//
//  Created by WangYing on 17/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager()
    @property (nonatomic, strong) NSString *documentsDirectory;
    @property (nonatomic, strong) NSString *databaseFileName;
@end

@implementation DBManager

+ (instancetype)instance
{
    static DBManager* _self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      _self = [[DBManager alloc] init];
                  });
    return _self;
}

- (void)openDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *databasePath = [[documentPath stringByAppendingString:@"/"] stringByAppendingString:@"dashcam.db"];

    self.appDatabase = [FMDatabase databaseWithPath:databasePath];
    if (![self.appDatabase open]) {
        self.appDatabase = nil;
        return;
    }

    // check table exist for video record and if not exist, then create table
    BOOL success = [self.appDatabase executeStatements:@"CREATE TABLE IF NOT EXISTS tbl_video_record (id integer primary key autoincrement, videoname text, s_latitude integer, s_longitude integer, e_latitude integer, e_longitude integer);"];
    if (!success) {
        NSLog(@"error = %@", [self.appDatabase lastErrorMessage]);
    }
}

- (void)closeDatabase
{
    if (self.appDatabase != nil)
        [self.appDatabase close];
}

- (NSInteger)fetchVideoRecordCound
{
    return 0;
}

- (VideoTableRecord*)fetchVideoRecord:(NSString*)videoName
{
    VideoTableRecord* videoRecord = nil;
    FMResultSet *s = [self.appDatabase executeQuery:@"SELECT * FROM tbl_video_record WHERE videoname = ?", videoName];

    if (!s) {
        NSLog(@"error = %@", [self.appDatabase lastErrorMessage]);
    } else {
        if ([s next]) {
            videoRecord = [[VideoTableRecord alloc] init];
            [videoRecord setValuesName:[s stringForColumn:@"videoname"] sLat:[s intForColumn:@"s_latitude"] sLon:[s intForColumn:@"s_longitude"] eLat:[s intForColumn:@"e_latitude"] eLon:[s intForColumn:@"e_longitude"]];
        } else {
            NSLog(@"error = No record found");
        }
    }

    return videoRecord;
}

- (BOOL)insertVideoRecord:(NSString*)videoName sLat:(NSInteger)slat sLon:(NSInteger)slon eLat:(NSInteger)elat eLon:(NSInteger)elon
{
    BOOL success = [self.appDatabase executeUpdate:@"INSERT INTO tbl_video_record (videoname, s_latitude, s_longitude, e_latitude, e_longitude) VALUES (?, ?, ?, ?, ?)", videoName, @(slat), @(slon), @(elat), @(elon) ?: [NSNull null]];
    if (!success) {
        NSLog(@"error = %@", [self.appDatabase lastErrorMessage]);
    }
    
    return success;
}

- (BOOL)updateVideoRecordName:(NSString*)videoName with:(NSString*)newName
{
    BOOL success = [self.appDatabase executeUpdate:@"UPDATE tbl_video_record SET videoname = ? WHERE videoname = ?", videoName, newName];
    if (!success) {
        NSLog(@"error = %@", [self.appDatabase lastErrorMessage]);
    }
    return success;
}

- (BOOL)deleteVideoRecord:(NSString*)videoName
{
    BOOL success = [self.appDatabase executeUpdate:@"DELETE FROM tbl_video_record WHERE videoname = ?", videoName];
    if (!success) {
        NSLog(@"error = %@", [self.appDatabase lastErrorMessage]);
    }
    return success;
}

- (BOOL)clearVideoRecords
{
    BOOL success = [self.appDatabase executeUpdate:@"DELETE FROM tbl_video_record"];
    if (!success) {
        NSLog(@"error = %@", [self.appDatabase lastErrorMessage]);
    }
    return success;
}


@end
