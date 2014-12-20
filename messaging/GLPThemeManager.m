//
//  GLPThemeManager.m
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPThemeManager.h"
#import "GLPStanfordTheme.h"
#import "GLPDefaultTheme.h"
#import "AppearanceHelper.h"

@interface GLPThemeManager()

@property (strong, nonatomic) GLPTheme *selectedTheme;

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
        self.selectedTheme = [[GLPStanfordTheme alloc] init];
    }
    else
    {
        self.selectedTheme = [[GLPDefaultTheme alloc] init];
    }
}

-(UIColor*)colorForTabBar
{
    return [self.selectedTheme tabbarColour];
}

-(NSString*)imageForChatBackground
{
    return [self.selectedTheme chatBackground];
}

-(NSString*)imageForNavBar
{
    return [self.selectedTheme navbar];
}

-(NSString*)pullDownButton
{
    return [self.selectedTheme pullDownImage];
}

#pragma mark - New implementation

- (UIImage *)navigationBarImage
{
    return [self.selectedTheme navigationBarImage];
}

- (UIImage *)leftItemColouredImage:(UIImage *)leftImage
{
    return [self.selectedTheme leftItemColouredImage:leftImage];
}

- (UIImage *)rightItemColouredImage:(UIImage *)rightImage
{
    return [self.selectedTheme rightItemColouredImage:rightImage];
}

- (UIColor *)navigationBarColour
{
    return [self.selectedTheme firstColour];
}

- (UIColor *)navigationBarTitleColour
{
    return [self.selectedTheme fourthColour];
}

- (UIColor *)campusWallNavigationBarTitleColour
{
    return [self.selectedTheme fifthColour];
}

- (UIColor *)nameTintColour
{
    return [self.selectedTheme fifthColour];
}

- (UIColor *)tabbarSelectedColour
{
    return [self.selectedTheme fifthColour];
}

- (UIColor *)tabbarUnselectedColour
{
    return [AppearanceHelper colourForRegisterTextFields];
}

-(GLPThemeType)themeIdentifier
{
    return [self.selectedTheme identifier];
}

- (NSString *)appNameWithString:(NSString *)string
{    
    return [NSString stringWithFormat:string, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
}

- (NSString *)lowerCaseAppName
{
    return [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]].lowercaseString;
}

@end