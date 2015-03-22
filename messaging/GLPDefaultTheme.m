//
//  GLPDefaultTheme.m
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPDefaultTheme.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"

@implementation GLPDefaultTheme

NSString *CAMPUS_WALL_TITLE = @"STANFORD WALL";

-(id)init
{
//    self = [super initWithIdentifier:kGLPDefaultTheme chatBackground:@"new_chat_background" navbarImageName:@"navigationbar2" tabbarTintColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0] pullDownImage:@"pull_down_button"];
    
//    self = [super initWithIdentifier:kGLPDefaultTheme firstColour:[UIColor whiteColor]  secondColour:[AppearanceHelper blueGleepostColour] thirdColour:[AppearanceHelper greenGleepostColour] fourthColour:[AppearanceHelper blackGleepostColour] fifthColour:[AppearanceHelper redGleepostColour]];
//
    self = [super init];
    
    if(self)
    {
        [self configureColours];
    }
    
    return  self;
}

- (void)configureColours
{
    _primaryColour = [AppearanceHelper redGleepostColour];
    _leftNavBarElementColour =[AppearanceHelper blueGleepostColour];
    _rightNavBarElementColour = [AppearanceHelper greenGleepostColour];
    _navBarBackgroundColour = [UIColor whiteColor];
    _campusWallTitleColour = [AppearanceHelper redGleepostColour];
    _generalNavBarTitleColour = [AppearanceHelper blackGleepostColour];
}

- (UIImage *)navigationBarImage
{
    UIImage *image = [UIImage imageNamed:@"navigation_bar_new_post"];
    return [self.navBarBackgroundColour filledImageFrom:image];
}

- (UIImage *)leftItemColouredImage:(UIImage *)leftImage
{
    return [self.leftNavBarElementColour filledImageFrom:leftImage];
}

- (UIImage *)rightItemColouredImage:(UIImage *)rightImage
{
    return [self.rightNavBarElementColour filledImageFrom:rightImage];
}

- (NSString *)campusWallTitle
{
    return CAMPUS_WALL_TITLE;
}

@end