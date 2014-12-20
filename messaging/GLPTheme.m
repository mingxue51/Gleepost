//
//  GLPTheme.m
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPTheme.h"
#import "UIColor+GLPAdditions.h"

@implementation GLPTheme

-(id)initWithIdentifier:(GLPThemeType)identifier chatBackground:(NSString*)chatBackground navbarImageName:(NSString*)navBar tabbarTintColour:(UIColor*)tabbarColour pullDownImage:(NSString*)pullDownImage
{
    self = [super init];
    
    if(self)
    {
        self.identifier = identifier;
        _chatBackground = chatBackground;
        _navbar = navBar;
        _tabbarColour = tabbarColour;
        _pullDownImage = pullDownImage;
    }
    
    return self;
}

/**
 
 @param fifthColour this colour should be used for tab bar.
 
*/

- (id)initWithIdentifier:(GLPThemeType)identifier firstColour:(UIColor *)firstColour secondColour:(UIColor *)secondColour thirdColour:(UIColor *)thirdColour fourthColour:(UIColor *)fourthColour fifthColour:(UIColor *)fifthColour
{
    self = [super init];
    
    if (self)
    {
        _identifier = identifier;
        _firstColour = firstColour;
        _secondColour = secondColour;
        _thirdColour = thirdColour;
        _fourthColour = fourthColour;
        _fifthColour = fifthColour;
    }
    return self;
}

// Navigation bar will have the first colour.

- (UIImage *)navigationBarImage
{
    UIImage *image = [UIImage imageNamed:@"navigation_bar_new_post"];
    
    return [self.firstColour filledImageFrom:image];
}

- (UIImage *)leftItemColouredImage:(UIImage *)leftImage
{
    return [self.secondColour filledImageFrom:leftImage];
}

- (UIImage *)rightItemColouredImage:(UIImage *)rightImage
{
    return [self.thirdColour filledImageFrom:rightImage];
}

@end
