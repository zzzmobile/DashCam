//
//  SettingsViewController.h
//  DashCamera
//
//  Created by WangYing on 06/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tblSetting;
@property (weak, nonatomic) IBOutlet UIView *adsView;

- (IBAction)onSaveSettings:(id)sender;

@end
