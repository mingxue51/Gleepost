//
//  ProfileTopViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 25/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopTableViewCell.h"
#import "GLPSegmentView.h"

@class GLPUser;

@protocol ProfileTopViewCellDelegate <NSObject>

@required
- (void)changeProfileImage:(id)sender;
- (void)segmentSwitchedWithButtonType:(ButtonType)buttonType;

@end

@interface ProfileTopViewCell : TopTableViewCell <GLPSegmentViewDelegate, TopTableViewCellDelegate>

extern const float PROFILE_TOP_VIEW_HEIGHT;

@property (weak, nonatomic) UIViewController <ProfileTopViewCellDelegate> *delegate;

- (void)setUserData:(GLPUser *)userData;
- (void)showNotificationBubbleWithNotificationCount:(int)notificationCount;
- (void)hideNotificationBubble;
- (void)comesFromPushNotification:(BOOL)fromPN;
@end
