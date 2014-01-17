//
//  AppearanceHelper.h
//  Gleepost
//
//  Created by Lukas on 10/16/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppearanceHelper : NSObject

+ (void)setNavigationBarBackgroundImageFor:(UIViewController *)controller imageName:(NSString *)imageName forBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setNavigationBarBlurBackgroundFor:(UIViewController *)contoller WithImage:(NSString*)imageName;
+ (void)setNavigationBarColour:(UIViewController *)controller;
+(void)setNavigationBarFontFor: (UIViewController *)controller;
+(void)formatTextWithLabel:(UILabel*)label withSize:(float)size;
+(void)setUnselectedColourForTabbarItem:(UITabBarItem *)item;
+(void)setSelectedColourForTabbarItem:(UITabBarItem *)item withColour:(UIColor *)colour;
+(UIColor*)colourForNotFocusedItems;
+(UIColor*)defaultGleepostColour;

@end
