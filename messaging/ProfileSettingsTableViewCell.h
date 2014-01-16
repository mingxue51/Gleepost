//
//  ProfileSettingsTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPProfileViewController.h"

@protocol ProfileSettingsTableViewCellDelegate;

@interface ProfileSettingsTableViewCell : UITableViewCell
@property (nonatomic, weak) id <ProfileSettingsTableViewCellDelegate> delegate;
@end

@protocol ProfileSettingsTableViewCellDelegate <NSObject>
@optional
- (void)logout:(id)sender;
- (void)share;
@end
