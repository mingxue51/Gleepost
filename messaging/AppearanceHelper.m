//
//  AppearanceHelper.m
//  Gleepost
//
//  Created by Lukas on 10/16/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "AppearanceHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "GLPiOS6Helper.h"
#import "UIColor+GLPAdditions.h"

@implementation AppearanceHelper

+ (void)setNavigationBarBackgroundImageFor:(UIViewController *)controller imageName:(NSString *)imageName forBarMetrics:(UIBarMetrics)barMetrics
{
    UIImage *image = [UIImage imageNamed:imageName];
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [controller.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:barMetrics];
    } else {
        [controller.navigationController.navigationBar setBackgroundImage:image forBarMetrics:barMetrics];
    }
}

+(void)setNavigationBarColour:(UIViewController *)controller
{
    //75, 208, 210
//    UIColor *barColour = [UIColor colorWithRed:0.0f/255.0f green:201.0f/255.0f blue:201.0f/255.0f alpha:1.0];
//    
//    [controller.navigationController.navigationBar setBarTintColor: barColour];
    
    //In order to hide shadow image we are adding background image as a background to the navigation bar and the remove shadow image.
    
    
    
    UINavigationBar *navigationBar = controller.navigationController.navigationBar;
    
    if([GLPiOS6Helper isIOS6])
    {
//        [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_stanford_final"] forBarMetrics:UIBarMetricsDefault];
        
        [navigationBar setTintColor:[AppearanceHelper defaultGleepostColour]];
 //       [[UINavigationBar appearance] setTintColor:[AppearanceHelper defaultGleepostColour]];
        
//        [controller.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];

        

    }
    else
    {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_stanford_final"]
                           forBarPosition:UIBarPositionAny
                               barMetrics:UIBarMetricsDefault];
        
    }
    
    [navigationBar setShadowImage:[UIImage new]];

}

+ (void)setWhiteNavigationBarFormat:(UINavigationBar *)navigationBar
{    
    if([GLPiOS6Helper isIOS6])
    {
        //        [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_stanford_final"] forBarMetrics:UIBarMetricsDefault];
        
        [navigationBar setTintColor:[AppearanceHelper defaultGleepostColour]];
        //       [[UINavigationBar appearance] setTintColor:[AppearanceHelper defaultGleepostColour]];
        
        //        [controller.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
        
        
        
    }
    else
    {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_new_post"]
                           forBarPosition:UIBarPositionAny
                               barMetrics:UIBarMetricsDefault];
        
    }
    
    [navigationBar setShadowImage:[UIImage new]];
}

+(void)setNavigationBarFontFor: (UIViewController *)controller
{
//    [controller.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_APP_FONT size:20.0f], UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil]];
    
    if([GLPiOS6Helper isIOS6])
    {
       return;
    }
    
    [controller.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_TITLE_FONT size:20.0f], UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil]];

    
    [controller.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
//    [[UINavigationBar appearance] setTitleTextAttributes: @{UITextAttributeFont: [UIFont fontWithName:@"Helvetica Neue" size:20.0f]}];

}

+(void)setNavigationBarFontForNavigationBar: (UINavigationBar *)navigationBar
{

    if([GLPiOS6Helper isIOS6])
    {
        [navigationBar setTintColor:[AppearanceHelper defaultGleepostColour]];
        CGRectSetH(navigationBar, 60.0f);
        CGRectMoveY(navigationBar, -19.0f);
        
        [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_TITLE_FONT size:18.0f], UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil]];
    }
    else
    {
        
        //Tag = 1 is used for custom navigation bars. (with white background)
        //Tag = 2 is used for default navigation bars. (with white background)
        //Tag = 0 is used for all navigation bars. (with other than white background)
        if(navigationBar.tag == 1)
        {
            CGRectSetH(navigationBar, 65.0f);
            CGRectMoveY(navigationBar, -22.0f);
            [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_TITLE_FONT size:18.0f], UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil]];
        }
        else if (navigationBar.tag == 2)
        {
            [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_TITLE_FONT size:18.0f], UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil]];
        }
        else
        {
            [navigationBar setTintColor:[UIColor whiteColor]];
            [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_TITLE_FONT size:18.0f], UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil]];
        }
    }
    
}

+(void)setNavigationBarFormatForNewPostViews:(UINavigationBar *)navigationBar
{
    [AppearanceHelper setNavigationBarFontForNavigationBar:navigationBar];
    
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_new_post"]
                            forBarPosition:UIBarPositionAny
                                barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
}


+(void)setSegmentFontWithSegment:(UISegmentedControl *)segment
{
    [segment setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:GLP_TITLE_FONT size:16.0f], UITextAttributeFont, nil] forState:UIControlStateNormal];
}

+(void)formatTextWithLabel:(UILabel*)label withSize:(float)size
{
    [label setFont:[UIFont fontWithName:GLP_APP_FONT size:size]];
}

#pragma mark - Tabbar

+(void)setUnselectedColourForTabbarItem:(UITabBarItem *)item
{    
    float rgb = 210.0;
    
    UIColor *colour = [UIColor colorWithR:rgb withG:rgb andB:rgb];

    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    

    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:colour , UITextAttributeTextColor, font, NSFontAttributeName, nil] forState:UIControlStateNormal];
}

+(void)setSelectedColourForTabbarItem:(UITabBarItem *)item withColour:(UIColor *)colour
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: colour, UITextAttributeTextColor, font, NSFontAttributeName, nil] forState:UIControlStateSelected];
}

+(UIColor*)defaultGleepostColour
{
//    return [UIColor colorWithRed:0.0/255.0f green:201.0/255.0f blue:201.0/255.0f alpha:1.0];
    return [UIColor colorWithRed:28.0/255.0f green:207.0/255.0f blue:208.0/255.0f alpha:1.0];
}

+ (UIColor *)grayGleepostColour
{
    return [UIColor colorWithR:152 withG:152 andB:152];
}

+ (UIColor *)redGleepostColour
{
    return [UIColor colorWithR:241 withG:91 andB:104]; //221, 71, 84
}

+ (UIColor *)colourForNotFocusedItems
{
    return [UIColor colorWithR:227.0 withG:227.0 andB:227.0];
    
//    return [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
}

+ (UIColor *)colourForUnselectedSegment
{
    return [UIColor colorWithR:175.0 withG:175.0 andB:175.0];
}

+ (UIColor *)colourForRegisterTextFields
{
    return [UIColor colorWithR:200.0 withG:200.0 andB:200.0];  //187 186 196
}

+(UIColor *)colourForTableViewSeparatorLines
{
    return [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
}


+(void)showTabBar:(UIViewController*)controller
{
    controller.tabBarController.tabBar.hidden = NO;
}

+(void)hideTabBar:(UIViewController*)controller
{
    controller.tabBarController.tabBar.hidden = YES;
}

/**
 Sets custom background in order to have different colour on top and different colour in botton of the view.
 */

+(void)setCustomBackgroundToTableView:(UITableView *)tableView
{
    UIImageView *backImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"campus_wall_background_main"]];
    
    [backImgView setFrame:CGRectMake(0.0f, 0.0f, backImgView.frame.size.width, backImgView.frame.size.height)];
    
    [tableView setBackgroundColor:[AppearanceHelper defaultGleepostColour]];
    [tableView setBackgroundView:backImgView];
}


+(void)setFormatForLoginNavigationBar:(UIViewController*)viewController
{
    [viewController.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:GLP_APP_FONT_BOLD size:24.0f], UITextAttributeFont, nil]];
    
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    viewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

+(UIColor*)colourOfTheFakeNavigationBar
{
    return [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:247.0/255.0 alpha:1.0f];
}


//TODO: Fix this working with iOS 6.
+ (void)setNavigationBarBlurBackgroundFor:(UIViewController *)contoller WithImage:(NSString*)imageName
{
//    UIImage *image = [UIImage imageNamed:imageName];
    
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
