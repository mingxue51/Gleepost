//
//  GroupViewController.h
//  Gleepost
//
//  Created by Silouanos on 04/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPGroup.h"
#import "NewCommentDelegate.h"
#import "ViewImageDelegate.h"
#import "ButtonNavigationDelegate.h"
#import "NewPostDelegate.h"

@interface GroupViewController : UITableViewController<NewCommentDelegate, ViewImageDelegate, ButtonNavigationDelegate, NewPostDelegate>

@property (strong, nonatomic) GLPGroup *group;

@end