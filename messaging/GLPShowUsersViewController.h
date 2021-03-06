//
//  GLPShowUsersViewController.h
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPShowUsersViewController : UIViewController

@property (strong, nonatomic) NSString *selectedTitle;

@property (strong, nonatomic) NSArray *users;

@property (assign, nonatomic) NSInteger postRemoteKey;

@property (assign, nonatomic) BOOL transparentNavBar;

@end
