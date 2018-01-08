//
//  Tools.m
//  DashCamera
//
//  Created by WangYing on 08/01/2018.
//  Copyright © 2018 WAC. All rights reserved.
//

#import "Tools.h"

@implementation Tools

+ (void)addLeftNavBarButtonWithImage:(NSString*)imageName
                               title:(NSString*)title
                               forVC:(UIViewController*)targetVC
                              action:(SEL)action
{
    [self addBarButtonItemWithImage:imageName title:title forVC:targetVC action:action isLeft:YES];
}

+ (void)addRightNavBarButtonWithImage:(NSString*)imageName
                                title:(NSString*)title
                                forVC:(UIViewController*)targetVC
                               action:(SEL)action
{
    [self addBarButtonItemWithImage:imageName title:title forVC:targetVC action:action isLeft:NO];
}

+ (void)addBarButtonItemWithImage:(NSString*)imageName
                            title:(NSString*)title
                            forVC:(UIViewController*)targetVC
                           action:(SEL)action
                           isLeft:(BOOL)isLeft
{
    NSParameterAssert((imageName || title) && targetVC);
    
    UIBarButtonItem *button;
    
    if (imageName)
    {
        button = [[UIBarButtonItem alloc]
                  initWithImage:[UIImage imageNamed:imageName]
                  style:UIBarButtonItemStylePlain
                  target:targetVC
                  action:action];
        
        if (title)
            button.title = title;
    }
    else
    {
        button = [[UIBarButtonItem alloc]
                  initWithTitle:title
                  style:UIBarButtonItemStylePlain
                  target:targetVC
                  action:action];
    }
    
    if (isLeft)
        targetVC.navigationItem.leftBarButtonItem = button;
    else
        targetVC.navigationItem.rightBarButtonItem = button;
}

@end
