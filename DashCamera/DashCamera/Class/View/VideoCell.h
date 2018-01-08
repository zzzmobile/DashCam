//
//  VideoCell.h
//  DashCamera
//
//  Created by WangYing on 08/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface VideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivVideo;
@property (weak, nonatomic) IBOutlet UILabel *lblVideoName;
@property (weak, nonatomic) IBOutlet UILabel *lblVideoTimeStamp;
@property (weak, nonatomic) IBOutlet UILabel *lblVideoSize;

@property (nonatomic) VideoModel *videoModel;

- (void)setVideoPath:(NSString*)path;
- (void)setup;

@end
