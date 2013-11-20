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

@interface ProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, FDTakeDelegate, NewCommentDelegate>

@property (strong, nonatomic) GLPUser* incomingUser;
@property (assign, nonatomic) BOOL isUserJustAccepted;

@end
