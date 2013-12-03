//
//  GLPThemeManager.m
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPThemeManager.h"
#import "GLPTheme.h"
#import "GLPStanfordTheme.h"
#import "GLPDefaultTheme.h"

@interface GLPThemeManager()

@property (strong, nonatomic) GLPTheme *type;

@end

@implementation GLPThemeManager

NSString * const stanfordUniversity = @"University of Leeds";

static GLPThemeManager *instance = nil;

+(GLPThemeManager*)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPThemeManager alloc] init];
    });
    
    return instance;
}

//TODO: Do this after testing.

//-(id)init
//{
//    self = [super init];
//    
//    if(self)
//    {
//        //Set default when network did not set before.
//        [self setNetwork:@""];
//    }
//    
//    return self;
//}

-(void)setNetwork:(NSString*)network
{
    if([network isEqualToString:stanfordUniversity])
    {
        self.type = [[GLPStanfordTheme alloc] init];
    }
    else
    {
        self.type = [[GLPDefaultTheme alloc] init];
    }
}

-(UIColor*)colorForTabBar
{
    return [self.type tabbarColour];
}

-(NSString*)imageForChatBackground
{
    return [self.type chatBackground];
}

-(NSString*)imageForNavBar
{
    return [self.type navbar];
}

-(NSString*)pullDownButton
{
    return [self.type pullDownImage];
}

@end
