//
//  GLPThemeManager.h
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPTheme.h"

@interface GLPThemeManager : NSObject

+(GLPThemeManager*)sharedInstance;

-(void)setNetwork:(NSString*)network;
-(NSString*)imageForChatBackground;
-(NSString*)imageForNavBar;
-(UIColor*)colorForTabBar;
-(NSString*)pullDownButton;
-(GLPThemeType)themeIdentifier;
- (UIImage *)navigationBarImage;
- (UIImage *)leftItemColouredImage:(UIImage *)leftImage;
- (UIImage *)rightItemColouredImage:(UIImage *)rightImage;
- (UIColor *)navigationBarColour;
- (UIColor *)navigationBarTitleColour;
- (UIColor *)campusWallNavigationBarTitleColour;
- (UIColor *)nameTintColour;
- (UIColor *)tabbarSelectedColour;
- (UIColor *)tabbarUnselectedColour;
- (NSString *)appNameWithString:(NSString *)string;
- (NSString *)lowerCaseAppName;
@end
