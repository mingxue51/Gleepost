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
    
    UIColor *barColour = [UIColor colorWithRed:75.0/255.0 green:204.0/255.0 blue:210.0/255.0 alpha:0.8];
    
    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colourView.opaque = NO;
    colourView.alpha = .67f;
    colourView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    contoller.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    
    
    [contoller.navigationController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
    

    [contoller.navigationController.navigationBar setTranslucent:YES];
}
@end
