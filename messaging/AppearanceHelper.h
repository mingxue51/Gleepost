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

@end
