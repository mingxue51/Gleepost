//
//  GLPStanfordTheme.m
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPStanfordTheme.h"
#import "UIColor+GLPAdditions.h"
#import "AppearanceHelper.h"

@implementation GLPStanfordTheme

-(id)init
{
//    self = [super initWithIdentifier:kGLPStanfordTheme chatBackground:@"chat_background_default" navbarImageName:@"chat_background_default" tabbarTintColour: pullDownImage:@"mascot_stanford"];
    
    self = [super initWithIdentifier:kGLPStanfordTheme firstColour:[UIColor colorWithRed:174.0/255.0 green:16.0/255.0 blue:15.0/255.0 alpha:1.0] secondColour:[UIColor whiteColor] thirdColour:[UIColor blackColor] fourthColour:[AppearanceHelper blackGleepostColour] fifthColour:[AppearanceHelper lightGrayGleepostColour]];
    
    if(self)
    {
        
    }
    
    return  self;
}

@end
