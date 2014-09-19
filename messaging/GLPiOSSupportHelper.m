//
//  GLPiOS6Helper.m
//  Gleepost
//
//  Created by Σιλουανός on 11/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPiOSSupportHelper.h"

@implementation GLPiOSSupportHelper

+(void)configureTabbarController:(UITabBarController *)tabbar
{
    
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
