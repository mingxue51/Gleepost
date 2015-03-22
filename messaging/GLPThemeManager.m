//
//  GLPThemeManager.m
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPThemeManager.h"
#import "GLPDefaultTheme.h"
#import "AppearanceHelper.h"

@interface GLPThemeManager()

@property (strong, nonatomic) GLPDefaultTheme *selectedTheme;

@end

@implementation GLPThemeManager

static GLPThemeManager *instance = nil;

+(GLPThemeManager*)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[GLPThemeManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.selectedTheme = [[GLPDefaultTheme alloc] init];
    }
    
    return self;
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
    return [self.selectedTheme navBarBackgroundColour];
}

- (UIColor *)navigationBarTitleColour
{
    return [self.selectedTheme generalNavBarTitleColour];
}

- (UIColor *)campusWallNavigationBarTitleColour
{
    return [self.selectedTheme campusWallTitleColour];
}

- (UIColor *)nameTintColour
{
    return [self.selectedTheme primaryColour];
}

- (UIColor *)tabbarSelectedColour
{
    return [self.selectedTheme primaryColour];
}

- (UIColor *)tabbarUnselectedColour
{
    return [AppearanceHelper colourForRegisterTextFields];
}

- (NSString *)campusWallTitle
{
    return  [self.selectedTheme campusWallTitle];
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