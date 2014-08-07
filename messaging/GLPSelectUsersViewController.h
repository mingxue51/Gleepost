//
//  GLPSelectUsersViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 30/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class is used for just as a parent class of View Controllers that have
//  the functionality of selecting users.
//  This class is used ONLY as a super class.

//  Current children classes: GLPInviteUsersViewController, NewGroupMessageViewController.

#import <UIKit/UIKit.h>
#import "GLPSearchBar.h"

@class GLPUser;

@protocol GLPSelectUsersViewControllerDelegate <NSObject>

- (void)reloadTableView;

@end

@interface GLPSelectUsersViewController : UIViewController <GLPSearchBarDelegate>

@property (assign, nonatomic) UIViewController <GLPSelectUsersViewControllerDelegate> *delegate;

@property (strong, nonatomic) NSMutableArray *searchedUsers;

@property (strong, nonatomic) NSMutableArray *checkedUsers;

@property (strong, nonatomic) GLPSearchBar *glpSearchBar;

@property (weak, nonatomic) IBOutlet UIView *searchBarView;

@property (strong, nonatomic) NSArray *alreadyMembers;

@property (assign, nonatomic, getter = areSelectedUsersVisible) BOOL selectedUsersVisible;

- (void)initialiseObjects;
- (void)configureNavigationBar;
- (BOOL)isUserSelected:(GLPUser *)user;
- (NSInteger)removeUser:(GLPUser *)user;
- (BOOL)isCurrentUserFoundWithUsers:(NSArray *)users;
- (NSArray *)getCheckedUsersRemoteKeys;
- (void)resignFirstResponderOfGlpSearchBar;
- (void)userSelected;
- (void)userRemoved;
@end
