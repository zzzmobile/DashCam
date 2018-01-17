//
//  SettingValueCell.h
//  DashCamera
//
//  Created by WangYing on 11/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingValueCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tableCellName;
@property (weak, nonatomic) IBOutlet UILabel *tableCellValue;

+ (NSString*)reuseIdentifier;
+ (CGFloat)CellHeight;

- (void)setCellTitle:(NSString*)title;
- (void)setCellStringValue:(NSString*)value;
- (void)setCellIntegerValue:(NSInteger)value;
- (void)setCellBoolValue:(BOOL)value;

@end
