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
#import "GLPPostCell.h"
#import "PrivateProfileTopViewCell.h"
@interface GLPPrivateProfileViewController : UIViewController<NewCommentDelegate, GLPPostCellDelegate, PrivateProfileTopViewCellDelegate, ViewImageDelegate>


@property (assign, nonatomic) NSInteger selectedUserId;
@property (assign, nonatomic) BOOL showComment;
@property (assign, nonatomic) BOOL transparentNavBar;

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab;
-(void)viewConversation:(GLPConversation*)conversation;

@end
