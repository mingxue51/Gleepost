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
#import "ViewImageDelegate.h"
#import "NotificationCell.h"

@interface GLPProfileViewController : UITableViewController <UIActionSheetDelegate, FDTakeDelegate, NewCommentDelegate, ViewImageDelegate, GLPNotificationCellDelegate>


@property (strong, nonatomic) GLPPost *selectedPost;
@property (assign, nonatomic) int selectedUserId;

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab;
-(void)popUpNotifications:(id)sender;
-(void)logout:(id)sender;
-(void)changeProfileImage:(id)sender;

@end
