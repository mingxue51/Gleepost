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

-(id)initWithIdentifier:(GLPThemeType)identifier chatBackground:(NSString*)chatBackground andNavbarImageName:(NSString*)navBar andTabbarTintColour:(UIColor*)tabbarColour
{
    self = [super init];
    
    if(self)
    {
        self.identifier = identifier;
        _chatBackground = chatBackground;
        _navbar = navBar;
        _tabbarColour = tabbarColour;
    }
    
    return self;
}


@end
