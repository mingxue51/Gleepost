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
+ (UIColor *)borderGleepostColour;
+ (UIColor *)blueGleepostColour;
+ (UIColor *)borderMessengerGleepostColour;
+ (UIColor *)borderBlueMessengerGleepostColour;
+ (UIColor *)greenGleepostColour;
+ (UIColor *)blackGleepostColour;
+ (UIColor *)yellowGleepostColour;
+ (UIColor *)lightRedGleepostColour;
+ (UIColor *)mediumGrayGleepostColour;
+ (UIColor *)firstAutoColour;
+ (UIColor *)secondAutoColour;
+ (UIColor *)thirdAutoColour;
+ (UIColor *)fourthAutoColour;
+ (UIColor *)fifthAutoColour;
+ (UIColor *)sixthAutoColour;
+(UIColor*)defaultGleepostColour;
+ (UIColor *)redGleepostColour;
+(void)showTabBar:(UIViewController*)controller;
+(void)hideTabBar:(UIViewController*)controller;
+(void)setFormatForLoginNavigationBar:(UIViewController*)viewController;
+(UIColor*)colourOfTheFakeNavigationBar;
+(void)setCustomBackgroundToTableView:(UITableView *)tableView;
+(UIColor *)lightGrayGleepostColour;
+(void)setSegmentFontWithSegment:(UISegmentedControl *)segment;
+(void)setNavigationBarFontForNavigationBar: (UINavigationBar *)navigationBar;
+(void)setNavigationBarFormatForNewPostViews:(UINavigationBar *)navigationBar;
+ (void)makeBackDefaultButton;
@end
