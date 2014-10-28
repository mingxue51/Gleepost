//
//  GLPInviteUsersViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 30/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPCheckNameCell.h"
#import "GLPSelectUsersViewController.h"

@class GLPGroup;

@interface GLPInviteUsersViewController : GLPSelectUsersViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, GLPCheckNameCellDelegate, GLPSelectUsersViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) GLPGroup *group;
@property (strong, nonatomic) NSArray *alreadyMembers;

/** This variable should be YES only when this VC is called other than MembersVC, view controller. */
@property (assign, nonatomic, getter=doesNeedToReloadExistingMembers) BOOL needToReloadExistingMembers;

@end
