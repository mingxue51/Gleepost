//
//  UINavigationBar+Format.m
//  Gleepost
//
//  Created by Σιλουανός on 23/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UINavigationBar+Format.h"
#import "GLPiOSSupportHelper.h"
#import "AppearanceHelper.h"
#import "ImageFormatterHelper.h"
#import "UIColor+GLPAdditions.h"
#import "GLPThemeManager.h"

@implementation UINavigationBar (Format)

- (void)whiteBackgroundFormatWithShadow:(BOOL)shadow
{
    if([GLPiOSSupportHelper isIOS6])
    {
        //        [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_stanford_final"] forBarMetrics:UIBarMetricsDefault];
        
        [self setTintColor:[AppearanceHelper defaultGleepostColour]];
        //       [[UINavigationBar appearance] setTintColor:[AppearanceHelper defaultGleepostColour]];
        
        //        [controller.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    }
    else
    {
//        [self setTintColor:[UIColor redColor]];
        
//        [self setBackgroundImage:[UIImage imageNamed:@"navigation_bar_new_post"]
//                           forBarPosition:UIBarPositionAny
//                               barMetrics:UIBarMetricsDefault];
        
        [self setBackgroundImage:[[GLPThemeManager sharedInstance] navigationBarImage] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    [self setTranslucent:NO];
    
    if(shadow)
    {
        [self setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[AppearanceHelper mediumGrayGleepostColour]]];
    }
    else
    {
        [self setShadowImage:[UIImage new]];
    }
}

/**
 This method adds a black image view on top of the view controller view's
 a white image in order. This kind of procedure is used when the parent view controller (in the stack)
 has translucent navigation bar.
 
 @param shadow
 @param view view controller's view
 
 */

- (void)whiteBackgroundFormatWithShadow:(BOOL)shadow andView:(UIView *)view
{
    [self whiteBackgroundFormatWithShadow:shadow];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -64.0, [GLPiOSSupportHelper screenWidth], 64.0)];
    
    [topView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 63.0, [GLPiOSSupportHelper screenWidth], 1.0)];
    
    imgView.image = [ImageFormatterHelper generateOnePixelHeightImageWithColour:[AppearanceHelper mediumGrayGleepostColour]];
    
    [topView addSubview:imgView];

    
    [view addSubview:topView];
}

- (void)whiteTranslucentBackgroundFormatWithShadow:(BOOL)shadow andView:(UIView *)view
{
    [self setTranslucent:YES];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [GLPiOSSupportHelper screenWidth], 64.0)];
    
    [topView setBackgroundColor:[[GLPThemeManager sharedInstance] navigationBarColour]];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 63.0, [GLPiOSSupportHelper screenWidth], 1.0)];
    
    imgView.image = [ImageFormatterHelper generateOnePixelHeightImageWithColour:[AppearanceHelper mediumGrayGleepostColour]];
    
    [topView addSubview:imgView];
    
    
    [view addSubview:topView];
}

- (void)setFontFormatWithColour:(GLPColour)colour
{
    
    if([GLPiOSSupportHelper isIOS6])
    {
        return;
    }
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:15.0f], NSFontAttributeName, [[GLPThemeManager sharedInstance] navigationBarTitleColour], NSForegroundColorAttributeName, nil]];
    
    NSString *string = self.topItem.title;
    
    self.topItem.title = [string uppercaseString];

    [self setTintColor:[AppearanceHelper blueGleepostColour]];
}

- (void)setCampusWallFontFormat
{
    if([GLPiOSSupportHelper isIOS6])
    {
        return;
    }
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:15.0f], NSFontAttributeName, [[GLPThemeManager sharedInstance] campusWallNavigationBarTitleColour], NSForegroundColorAttributeName, nil]];
    
    NSString *string = self.topItem.title;
    
    self.topItem.title = [string uppercaseString];
    
    [self setTintColor:[self colourWithGLPColour:kRed]];
}

#pragma mark - For group VC

- (void)invisible
{
    [self setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"]
              forBarPosition:UIBarPositionAny
                  barMetrics:UIBarMetricsDefault];
    
    self.shadowImage = [UIImage new];
    self.translucent = YES;
//    self.backgroundColor = [UIColor clearColor];
//    self.topItem.titleView = nil;
    self.topItem.title = @"";
    [self setTintColor:[AppearanceHelper blueGleepostColour]];

}

#pragma mark - Helpers

- (UIColor *)colourWithGLPColour:(GLPColour)glpColour
{
    UIColor *tintColour = nil;
    
    if(glpColour == kBlack)
    {
        tintColour = [AppearanceHelper blackGleepostColour];
    }
    else if (glpColour == kRed)
    {
        tintColour = [AppearanceHelper redGleepostColour];
    }
    else if (glpColour == kWhite)
    {
        tintColour = [UIColor whiteColor];
    }
    else if (glpColour == kGreen)
    {
        tintColour = [AppearanceHelper greenGleepostColour];
    }
    
    return tintColour;
}

/**
 
 */
- (UIView *)generateViewWithLableWithTitle:(NSString *)title
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(85.0, 50.0, 150.0, 21.0)];
    
    [view setBackgroundColor:[UIColor clearColor]];
    
    [view setClipsToBounds:YES];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 21.0)];
    
    [titleLbl setFont:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:17.0]];
    
    [titleLbl setTextAlignment:NSTextAlignmentCenter];
    
    [titleLbl setText:title];
    
    [view addSubview:titleLbl];
    
    return view;
}

@end
