//
//  PrivateProfileTopViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 27/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopTableViewCell.h"

@class GLPConversation;
@class GLPUser;

@protocol PrivateProfileTopViewCellDelegate <NSObject>

@required
- (void)viewConversation:(GLPConversation *)conversation;
- (void)viewProfileImage:(UIImage *)image;

@end

@interface PrivateProfileTopViewCell : TopTableViewCell <TopTableViewCellDelegate>

extern const float PRIVATE_PROFILE_TOP_VIEW_HEIGHT;

@property (weak, nonatomic) UIViewController <PrivateProfileTopViewCellDelegate> *delegate;

- (void)setUserData:(GLPUser *)userData;

@end
