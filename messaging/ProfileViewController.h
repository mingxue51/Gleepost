//
//  ProfileViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 20/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"
#import "GLPUser.h"
#import "NewCommentDelegate.h"
#import "GLPPost.h"
#import "ViewImageDelegate.h"

@interface ProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, FDTakeDelegate, NewCommentDelegate, ViewImageDelegate>

@property (strong, nonatomic) GLPUser* incomingUser;
@property (strong, nonatomic) GLPPost *selectedPost;
@property (assign, nonatomic) int selectedUserId;
@end
