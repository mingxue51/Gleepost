//
//  GLPiOS6Helper.h
//  Gleepost
//
//  Created by Σιλουανός on 11/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPiOSSupportHelper : NSObject

+(void)configureTabbarController:(UITabBarController *)tabbar;
+(void)setBackgroundImageToTableView:(UITableView *)tableView;
+(BOOL)isIOS6;
+ (BOOL)isIOS7;

@end
