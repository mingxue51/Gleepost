//
//  AppearanceHelper.m
//  Gleepost
//
//  Created by Lukas on 10/16/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "AppearanceHelper.h"
#import <QuartzCore/QuartzCore.h>

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


//TODO: Fix this working with iOS 6.
+ (void)setNavigationBarBlurBackgroundFor:(UIViewController *)contoller WithImage:(NSString*)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    
//    UIColor *barColour = [UIColor colorWithRed:0.0/255.0f green:201.0/255.0f blue:201.0/255.0f alpha:1.0];

    UIColor *barColour = [UIColor colorWithRed:1.0/255.0f green:203.0/255.0f blue:205.0/255.0f alpha:1.0];
    
    //UIColor *barColour = [UIColor colorWithRed:27.0/255.0 green:198.0/255.0 blue:220.0/255.0 alpha:1];
    
    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colourView.opaque = NO;
    colourView.alpha = .4f;
    colourView.backgroundColor = barColour;
    
    [contoller.navigationController.navigationBar setBarTintColor: barColour];
    
    //[contoller.navigationController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
    

    [contoller.navigationController.navigationBar setTranslucent:NO];
}
@end
