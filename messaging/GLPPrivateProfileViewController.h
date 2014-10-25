//
//  GLPPrivateProfileViewController.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject_ProfileEnums.h"
#import "GLPConversation.h"
#import "ProfileTableViewCell.h"
#import "GLPPostCell.h"
#import "PrivateProfileTopViewCell.h"

@interface GLPPrivateProfileViewController : UITableViewController<NewCommentDelegate, GLPPostCellDelegate, PrivateProfileTopViewCellDelegate>


@property (assign, nonatomic) int selectedUserId;
@property (assign, nonatomic) BOOL showComment;

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab;
-(void)showFullProfileImage:(id)sender;
-(void)unlockProfile;
-(void)viewConversation:(GLPConversation*)conversation;

@end
