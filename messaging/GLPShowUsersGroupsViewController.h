//
//  GLPShowUsersGroupsViewController.h
//  Gleepost
//
//  Created by Silouanos on 21/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"
#import "GLPNewGroupsViewController.h"

@interface GLPShowUsersGroupsViewController : GLPNewGroupsViewController

@property (strong, nonatomic) GLPUser *user;

@end
