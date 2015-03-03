//
//  GLPiOS6Helper.m
//  Gleepost
//
//  Created by Σιλουανός on 11/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPiOSSupportHelper.h"

@implementation GLPiOSSupportHelper


/**
 @return YES if the app is running on iPhone 4(S).
 */
+ (BOOL)useShortConstrains
{
    return [UIScreen mainScreen].bounds.size.height == 480.0;
}

+ (CGFloat)screenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (BOOL)isIOS6
{
    return (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1);
}

+ (BOOL)isIOS7
{
    return (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 && ![GLPiOSSupportHelper isIOS6]);
}

+(void)setBackgroundImageToTableView:(UITableView *)tableView
{
    [tableView setBackgroundColor:[UIColor whiteColor]];
}

@end
