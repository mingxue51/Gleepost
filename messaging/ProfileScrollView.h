//
//  ProfileScrollView.h
//  Gleepost
//
//  Created by Σιλουανός on 29/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileScrollView : UIView

@property (strong, nonatomic) UISlider *activitySlider;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UIImageView *backProfileImageView;
@property (strong, nonatomic) UILabel *profileDetails;
@property (strong, nonatomic) UIView *socialPanel;
@property (strong, nonatomic) UILabel *postsLabel;
@property (strong, nonatomic) UILabel *profileViewsLabel;
@property (strong, nonatomic) UILabel *friendsLabel;
@property (strong, nonatomic) UILabel *rewardsLabel;

@end
