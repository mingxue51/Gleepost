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
#import "ProfileTableViewCell.h"
#import "FDTakeController.h"
#import "PostCell.h"


@interface GroupViewController : UITableViewController<NewCommentDelegate, ViewImageDelegate, ButtonNavigationDelegate, NewPostDelegate, UIActionSheetDelegate, ProfileTableViewCellDelegate, FDTakeDelegate, RemovePostCellDelegate>

@property (strong, nonatomic) GLPGroup *group;
@property (assign, nonatomic) BOOL fromPushNotification;
@end
