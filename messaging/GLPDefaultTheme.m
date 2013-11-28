//
//  GLPDefaultTheme.m
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPDefaultTheme.h"

@implementation GLPDefaultTheme

-(id)init
{
    self = [super initWithIdentifier:kGLPDefaultTheme chatBackground:@"chat_background_default" andNavbarImageName:@"navigationbar2" andTabbarTintColour:[UIColor colorWithRed:75.0/255.0 green:208.0/255.0 blue:210.0/255.0 alpha:1.0]];
    
    return  self;
}

@end
