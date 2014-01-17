//
//  GLPTheme.m
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPTheme.h"

@implementation GLPTheme

@synthesize chatBackground = _chatBackground;
@synthesize navbar = _navbar;
@synthesize tabbarColour = _tabbarColour;
@synthesize pullDownImage = _pullDownImage;

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


@end
