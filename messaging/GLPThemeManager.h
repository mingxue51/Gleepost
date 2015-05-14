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

- (UIImage *)navigationBarImage;
- (UIImage *)leftItemColouredImage:(UIImage *)leftImage;
- (UIImage *)rightItemColouredImage:(UIImage *)rightImage;
- (UIColor *)rightItemColour;
- (UIColor *)leftItemColour;
- (UIImage *)topItemColouredImage:(UIImage *)topImage;
- (UIColor *)navigationBarColour;
- (UIColor *)navigationBarTitleColour;
- (UIColor *)campusWallNavigationBarTitleColour;
- (UIColor *)nameTintColour;
- (UIColor *)tabbarSelectedColour;
- (UIColor *)tabbarUnselectedColour;
- (NSString *)campusWallTitle;
- (NSString *)appNameWithString:(NSString *)string;
- (NSString *)lowerCaseAppName;
@end
