//
//  ProfileButtonsTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPrivateProfileViewController.h"
#import "InvitationSentView.h"


@interface ProfileButtonsTableViewCell : UITableViewCell

extern const float BUTTONS_CELL_HEIGHT;


@property (readonly, nonatomic) GLPPrivateProfileViewController *delegate;
@property (strong, nonatomic) GLPUser *currentUser;
@property (strong, nonatomic) InvitationSentView *invitationSentView;


-(void)setDelegate:(GLPPrivateProfileViewController *)delegate;
//- (void)sendMessage:(id)sender;
- (void)addUser:(id)sender;

@end
