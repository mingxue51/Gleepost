//
//  GLPPrivateProfileViewController.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject_ProfileEnums.h"
#import "NewCommentDelegate.h"
#import "ViewImageDelegate.h"

@interface GLPPrivateProfileViewController : UITableViewController<NewCommentDelegate, ViewImageDelegate>


@property (assign, nonatomic) int selectedUserId;


-(void)viewSectionWithId:(GLPSelectedTab) selectedTab;
-(void)showFullProfileImage:(id)sender;
-(void)unlockProfile;

@end
