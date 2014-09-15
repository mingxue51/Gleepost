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
#import "NewCommentDelegate.h"
#import "GLPNotificationCell.h"
#import "ButtonNavigationDelegate.h"
#import "ProfileTableViewCell.h"
#import "GLPPostCell.h"
#import "ProfileTopViewCell.h"
#import "ImageSelectorViewController.h"

@interface GLPProfileViewController : UITableViewController <UIActionSheetDelegate, NewCommentDelegate, ViewImageDelegate, GLPImageViewDelegate, RemovePostCellDelegate, GLPPostCellDelegate, ProfileTopViewCellDelegate, ImageSelectorViewControllerDelegate>

@property (assign, nonatomic) BOOL fromPushNotification;
@property (assign, nonatomic) BOOL showComment;

-(void)changeProfileImage:(id)sender;

@end
