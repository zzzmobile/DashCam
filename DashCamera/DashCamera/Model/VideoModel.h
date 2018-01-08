//
//  VideoModel.h
//  DashCamera
//
//  Created by WangYing on 08/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VideoModel : NSObject

@property (nonatomic) NSString* filePath;
@property (nonatomic) NSString* fileName;
@property (nonatomic) UIImage* thumbImage;
@property (nonatomic) NSInteger timeStamp;    // seconds
@property (nonatomic) NSInteger fileSize;     // bytes

- (void)setVideoPath:(NSString*)videoPath;

@end
