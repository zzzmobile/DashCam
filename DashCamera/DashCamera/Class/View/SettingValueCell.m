//
//  SettingValueCell.m
//  DashCamera
//
//  Created by WangYing on 11/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "SettingValueCell.h"

@implementation SettingValueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // Configure the view for the selected state
    [super setSelected:selected animated:animated];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [super setSelected:NO animated:YES];
    });
}

- (void)setCellTitle:(NSString*)title
{
    [self.tableCellName setText:title];
}

- (void)setCellStringValue:(NSString*)value
{
    [self.tableCellValue setText:value];
}

- (void)setCellIntegerValue:(NSInteger)value
{
    [self.tableCellValue setText:[NSString stringWithFormat:@"%li", value]];
}

- (void)setCellBoolValue:(BOOL)value
{
    NSString* strBool = @"YES";
    if (!value)
        strBool = @"NO";
    
    [self.tableCellValue setText:strBool];
}

+ (NSString*)reuseIdentifier
{
    return @"SettingValueCell";
}

+ (CGFloat)CellHeight
{
    return 50;
}

@end
