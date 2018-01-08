//
//  VideoCell.m
//  DashCamera
//
//  Created by WangYing on 08/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setVideoPath:(NSString*)path
{
    self.videoModel = [[VideoModel alloc] init];
    [self.videoModel setVideoPath:path];
}

- (void)setup
{
    [self.ivVideo setImage:self.videoModel.thumbImage];
    [self.lblVideoName setText:self.videoModel.fileName];
    
    int minute = floor(self.videoModel.timeStamp / 60.0);
    int second = (int)self.videoModel.timeStamp - minute * 60;
    
    NSString *strMinute = [NSString stringWithFormat:@"%i", minute];
    if ([strMinute length] == 1)
        strMinute = [@"0" stringByAppendingString:strMinute];
    
    NSString *strSecond = [NSString stringWithFormat:@"%i", second];
    if ([strSecond length] == 1)
        strSecond = [@"0" stringByAppendingString:strSecond];
    
    NSString *strDurationTime = [strMinute stringByAppendingString:[@":" stringByAppendingString:strSecond]];
    [self.lblVideoTimeStamp setText:strDurationTime];
    
    int bytes = (int)self.videoModel.fileSize;
    float kBytes = bytes / 1024.0f;
    float mBytes = kBytes / 1024.0f;
    NSString *strSize = @"";
    
    if (mBytes >= 1) {
        strSize = [NSString stringWithFormat:@"%.1f", mBytes];
        strSize = [strSize stringByAppendingString:@"MB"];
    } else if (kBytes >= 1) {
        strSize = [NSString stringWithFormat:@"%.1f", kBytes];
        strSize = [strSize stringByAppendingString:@"KB"];
    } else {
        strSize = [NSString stringWithFormat:@"%i", bytes];
        strSize = [strSize stringByAppendingString:@"Byte"];
    }

    [self.lblVideoSize setText:strSize];
    
}

@end
