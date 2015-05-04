//
//  GLPDefaultTheme.h
//  Gleepost
//
//  Created by Σιλουανός on 28/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPTheme.h"

@interface GLPDefaultTheme : NSObject

/** Includes  tab bar highlight, user names on posts, colour login screen */
@property (strong, nonatomic) UIColor *primaryColour;
@property (strong, nonatomic) UIColor *leftNavBarElementColour;
@property (strong, nonatomic) UIColor *rightNavBarElementColour;
@property (strong, nonatomic) UIColor *navBarBackgroundColour;
@property (strong, nonatomic) UIColor *campusWallTitleColour;
@property (strong, nonatomic) UIColor *generalNavBarTitleColour;

- (UIImage *)navigationBarImage;
- (UIImage *)leftItemColouredImage:(UIImage *)leftImage;
- (UIImage *)rightItemColouredImage:(UIImage *)rightImage;
- (UIImage *)topItemColouredImage:(UIImage *)topImage;
- (NSString *)campusWallTitle;

@end
