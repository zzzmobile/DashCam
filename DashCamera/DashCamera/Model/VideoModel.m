//
//  VideoModel.m
//  DashCamera
//
//  Created by WangYing on 08/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "VideoModel.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoModel

- (void)setVideoPath:(NSString*)videoPath
{
    self.filePath = videoPath;
    [self getVideoData];
}

- (void)getVideoData
{
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    CMTime duration = [asset duration];
    self.timeStamp = ceil(duration.value / duration.timescale);
    self.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil] fileSize];
    self.fileName = [self.filePath lastPathComponent];
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    NSError *error = nil;
    CMTime time = CMTimeMakeWithSeconds(1, 2);
    CGImageRef ref = [imageGenerator copyCGImageAtTime:time actualTime:nil error:&error];

    self.thumbImage = [[UIImage alloc] initWithCGImage:ref];
}

@end
