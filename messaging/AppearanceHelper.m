//
//  AppearanceHelper.m
//  Gleepost
//
//  Created by Lukas on 10/16/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "AppearanceHelper.h"

@implementation AppearanceHelper

+ (void)setNavigationBarBackgroundImageFor:(UIViewController *)controller imageName:(NSString *)imageName forBarMetrics:(UIBarMetrics)barMetrics
{
    UIImage *image = [UIImage imageNamed:imageName];
    if(SYSTEM_VERSION_EQUAL_TO(@"7")) {
        [controller.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:barMetrics];
    } else {
        [controller.navigationController.navigationBar setBackgroundImage:image forBarMetrics:barMetrics];
    }
}

@end
