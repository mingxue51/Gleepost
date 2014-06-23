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
+ (void)setWhiteNavigationBarFormat:(UINavigationBar *)navigationBar;
+(void)setNavigationBarFontFor: (UIViewController *)controller;
+(void)formatTextWithLabel:(UILabel*)label withSize:(float)size;
+(void)setUnselectedColourForTabbarItem:(UITabBarItem *)item;
+(void)setSelectedColourForTabbarItem:(UITabBarItem *)item withColour:(UIColor *)colour;
+(UIColor*)colourForNotFocusedItems;
+ (UIColor *)colourForUnselectedSegment;
+ (UIColor *)colourForRegisterTextFields;
+ (UIColor *)grayGleepostColour;
+(UIColor*)defaultGleepostColour;
+ (UIColor *)redGleepostColour;
+(void)showTabBar:(UIViewController*)controller;
+(void)hideTabBar:(UIViewController*)controller;
+(void)setFormatForLoginNavigationBar:(UIViewController*)viewController;
+(UIColor*)colourOfTheFakeNavigationBar;
+(void)setCustomBackgroundToTableView:(UITableView *)tableView;
+(UIColor *)colourForTableViewSeparatorLines;
+(void)setSegmentFontWithSegment:(UISegmentedControl *)segment;
+(void)setNavigationBarFontForNavigationBar: (UINavigationBar *)navigationBar;
+(void)setNavigationBarFormatForNewPostViews:(UINavigationBar *)navigationBar;

@end
