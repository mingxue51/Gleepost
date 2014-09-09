//
//  GLPProfileViewController.h
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"
#import "NSObject_ProfileEnums.h"
#import "FDTakeController.h"
#import "NewCommentDelegate.h"
#import "NotificationCell.h"
#import "ButtonNavigationDelegate.h"
#import "ProfileTableViewCell.h"
#import "GLPPostCell.h"
#import "ProfileTopViewCell.h"

@interface GLPProfileViewController : UITableViewController <UIActionSheetDelegate, FDTakeDelegate, NewCommentDelegate, ViewImageDelegate, GLPNotificationCellDelegate, RemovePostCellDelegate, GLPPostCellDelegate, ProfileTopViewCellDelegate>

@property (assign, nonatomic) BOOL fromPushNotification;

-(void)logout:(id)sender;
-(void)changeProfileImage:(id)sender;

@end
