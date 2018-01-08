//
//  Tools.h
//  DashCamera
//
//  Created by WangYing on 08/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tools : NSObject

+ (void)addLeftNavBarButtonWithImage:(NSString*)imageName
                               title:(NSString*)title
                               forVC:(UIViewController*)targetVC
                              action:(SEL)action;

+ (void)addRightNavBarButtonWithImage:(NSString*)imageName
                                title:(NSString*)title
                                forVC:(UIViewController*)targetVC
                               action:(SEL)action;

@end
