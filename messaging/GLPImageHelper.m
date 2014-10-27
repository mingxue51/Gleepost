//
//  GLPImageHelper.m
//  Gleepost
//
//  Created by Silouanos on 23/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class has all the placeholders and returns them when it has been requested.

#import "GLPImageHelper.h"

@implementation GLPImageHelper

+ (UIImage *)placeholderUserImage
{
    return [UIImage imageNamed:[GLPImageHelper placeholderUserImagePath]];
}

+ (NSString *)placeholderUserImagePath
{
    return @"profile_placeholder";
}

+ (UIImage *)placeholderGroupImage
{
    return [UIImage imageNamed:[GLPImageHelper placeholderGroupImagePath]];
}

+ (UIImage *)placeholderLiveEventImage
{
    return [UIImage imageNamed:[GLPImageHelper placeholderLiveEventImagePath]];
}

+ (NSString *)placeholderLiveEventImagePath
{
    return @"campus_live_placeholder";
}

+ (NSString *)placeholderGroupImagePath
{
    return @"group_placeholder";
}

@end
