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
    
    if(shadow)
    {
        [self setShadowImage:[ImageFormatterHelper generateOnePixelHeightImageWithColour:[UIColor colorWithR:230.0 withG:230.0 andB:230.0]]];
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
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_TITLE_FONT size:22.0f], UITextAttributeFont, [self colourWithGLPColour:colour], UITextAttributeTextColor, nil]];
    

    [self setTintColor:[AppearanceHelper blueGleepostColour]];
}

- (void)setCampusWallFontFormat
{
    if([GLPiOS6Helper isIOS6])
    {
        return;
    }
    
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:GLP_CAMPUS_WALL_TITLE_FONT size:22.0f], UITextAttributeFont, [self colourWithGLPColour:kRed], UITextAttributeTextColor, nil]];
    
    
    [self setTintColor:[self colourWithGLPColour:kRed]];
}

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

@end
