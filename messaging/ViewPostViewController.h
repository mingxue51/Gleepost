//
//  ViewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPostCell.h"
#import "HPGrowingTextView.h"
#import "ViewImageDelegate.h"
#import "GLPPostCell.h"
#import "CommentCell.h"

@interface ViewPostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate, NewCommentDelegate, ViewImageDelegate, RemovePostCellDelegate, GLPPostCellDelegate, UIAlertViewDelegate, GLPImageViewDelegate, GLPLabelDelegate>

@property (strong, nonatomic) GLPPost *post;
//TODO: Remove after the integration of image posts.
@property (assign, nonatomic) NSInteger selectedUserId;
@property (assign, nonatomic) BOOL commentJustCreated;
@property (assign, nonatomic, getter = comesFromNotifications) BOOL isViewPostFromNotifications;

@property (assign, nonatomic) BOOL isFromCampusLive;
@property (strong, nonatomic) NSDate *commentNotificationDate;
@property (assign, nonatomic) BOOL showComment;

@property (weak, nonatomic) UIViewController <RemovePostCellDelegate> *groupController;

@end
