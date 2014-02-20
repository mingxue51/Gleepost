//
//  WebClientHelper.h
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebClientHelper : NSObject

+(void) showStandardLoaderWithTitle:(NSString *)title forView:(UIView *)view;
+ (void) showStandardLoaderWithoutSpinningAndWithTitle:(NSString*) title forView:(UIView *)view;
+(void) hideStandardLoaderForView:(UIView *)view;
+(void) showStandardErrorWithTitle:(NSString *)title andContent:(NSString *)content;
+(void) showStandardError;
+(void)showInternetConnectionErrorWithTitle:(NSString*)title;
+(void)showStandardEmailError;
+(void)showStandardPasswordError;

+(void)showStandardProfileImageError;
+(void)showStandardFirstNameError;

+(void)showStandardLastNameError;
+(void)showStandardFirstNameTooShortError;

+(void)showStandardLoginErrorWithMessage:(NSString *)message;

@end
