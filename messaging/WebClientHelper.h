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
+(void) hideStandardLoaderForView:(UIView *)view;
+(void) showStandardErrorWithTitle:(NSString *)title andContent:(NSString *)content;
+(void) showStandardError;

@end