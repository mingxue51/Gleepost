//
//  UINavigationBar+Format.m
//  Gleepost
//
//  Created by Σιλουανός on 23/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UINavigationBar+Format.h"
#import "GLPiOS6Helper.h"
#import "AppearanceHelper.h"
#import "ImageFormatterHelper.h"
#import "UIColor+GLPAdditions.h"

@implementation UINavigationBar (Format)

- (void)whiteBackgroundFormatWithShadow:(BOOL)shadow
{
    if([GLPiOS6Helper isIOS6])
    {
        //        [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_stanford_final"] forBarMetrics:UIBarMetricsDefault];
        
        [self setTintColor:[AppearanceHelper defaultGleepostColour]];
        //       [[UINavigationBar appearance] setTintColor:[AppearanceHelper defaultGleepostColour]];
        
        //        [controller.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil]];
    }
    else
    {
        [self setBackgroundImage:[UIImage imageNamed:@"navigation_bar_new_post"]
                           forBarPosition:UIBarPositionAny
                               barMetrics:UIBarMetricsDefault];
        
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

- (void)setFontFormatWithColour:(GLPColour)colour
{
    
    if([GLPiOS6Helper isIOS6])
    {
        return;
    }
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:17.0f], UITextAttributeFont, [self colourWithGLPColour:colour], UITextAttributeTextColor, nil]];
    
    NSString *string = self.topItem.title;
    
    self.topItem.title = [string uppercaseString];

    [self setTintColor:[AppearanceHelper blueGleepostColour]];
}

- (void)setCampusWallFontFormat
{
    if([GLPiOS6Helper isIOS6])
    {
        return;
    }
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:17.0], UITextAttributeFont, [self colourWithGLPColour:kRed], UITextAttributeTextColor, nil]];
    
    NSString *string = self.topItem.title;
    
    self.topItem.title = [string uppercaseString];
    
    [self setTintColor:[self colourWithGLPColour:kRed]];
}

#pragma mark - For group VC

- (void)invisible
{
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.shadowImage = [UIImage new];
    self.translucent = YES;
    self.backgroundColor = [UIColor clearColor];
    self.topItem.titleView = nil;
    self.topItem.title = @"";
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)makeVisibleWithTitle:(NSString *)title
{
//    [self.topItem.titleView setAlpha:0.0];
//    [self setAlpha:0.0];
    self.topItem.title = [title uppercaseString];
//    self.topItem.titleView = [self generateViewWithLableWithTitle:title];
    
    [self whiteBackgroundFormatWithShadow:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    
    
    
//    [UIView animateWithDuration:0.5 animations:^{
//       
//        [self.topItem.titleView setAlpha:1.0];
//
//        [self setAlpha:1.0];
//        
//    }];
//    
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
