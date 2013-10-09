//
//  ProfileScrollView.m
//  Gleepost
//
//  Created by Σιλουανός on 29/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileScrollView

@synthesize activitySlider;
@synthesize profileImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //Add the background image.
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        [self.backgroundImageView setAlpha:0.4];
        
        //Add effect to the image.
//        UIColor *pinkDarkOp;
//        UIColor *pinkLightOp;
//        CAGradientLayer *gradient;
//
//        
//        pinkDarkOp = [UIColor colorWithRed:15.0f/255.0 green:138.0f/255.0 blue:216.0f/255.0 alpha:0.7];
//        pinkLightOp = [UIColor colorWithRed:12.0f/255.0 green:91.0f/255.0 blue:183.0f/255.0 alpha:0.5];
//        
//        gradient = [CAGradientLayer layer];
//        gradient.frame = [[self.backgroundImageView layer] bounds];
//        gradient.colors = [NSArray arrayWithObjects:(id)pinkDarkOp.CGColor,(id)pinkLightOp.CGColor,nil];
//        gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.7],nil];
//        [[self.backgroundImageView layer] insertSublayer:gradient atIndex:0];
        
     
        
       
        [self addSubview:self.backgroundImageView];
        
        //Add the activity slider.
        self.activitySlider = [[UISlider alloc] initWithFrame:CGRectMake(230, 200, 80, 30)];
        
        UIImage *sliderLeftTrackImage = [UIImage imageNamed: @"typing_bar_small"];
        
        [self.activitySlider setTintColor:[UIColor colorWithPatternImage:sliderLeftTrackImage]];
        
       // UIImage *sliderLeftTrackImage = [UIImage imageNamed: @"typing_bar_small"];

       // [self.activitySlider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];

       // [self.activitySlider setThumbImage:[UIImage imageNamed: @"typing_bar_small"] forState: UIControlStateNormal];
        
        //Add the labels in activity slider.
        UILabel *labelBusy = [[UILabel alloc] initWithFrame:CGRectMake(230, 220, 80, 30)];
        [labelBusy setFont:[UIFont fontWithName:@"Helvetica Neue" size:10]];
        labelBusy.text = @"Busy";
        
        UILabel *labelFree = [[UILabel alloc] initWithFrame:CGRectMake(290, 220, 80, 30)];
        [labelFree setFont:[UIFont fontWithName:@"Helvetica Neue" size:10]];
        labelFree.text = @"Free";
        
        [self addSubview:labelBusy];
        [self addSubview:labelFree];
        
        [self addSubview:self.activitySlider];
        
        
        //Add the background profile image.
        UIImage *profileFrame = [UIImage imageNamed:@"profile_image_frame"];
        self.backProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 114, 100, 100)];
        [self.backProfileImageView setImage:profileFrame];
        
        
        [self addSubview:self.backProfileImageView];
        
        
        //Create and add profile details.
        self.profileDetails = [[UILabel alloc] initWithFrame:CGRectMake(85, 30, 300, 100)];
        [self.profileDetails setFont:[UIFont fontWithName:@"Helvetica Neue" size:10]];
        [self.profileDetails setText:@"Cambridge University  -  Marketing"];
        
        [self addSubview:self.profileDetails];
        
        
        //Create and add elements on social panel.
        self.socialPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 250, 320, 50)];
        UIColor *backColour = [UIColor colorWithWhite:1.0f alpha:0.5f];
        [self.socialPanel setBackgroundColor:backColour];
        
        //Create and add the panel's labels.
        //Create and add the number of posts label.
        self.postsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -5, 50, 50)];
        [self.postsLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [self.postsLabel setTextColor:[UIColor grayColor]];
        [self.postsLabel setText:@"126"];
        
        //Add post title.
        UILabel *postTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 10, 50, 50)];
        [postTitleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:8]];
        [postTitleLabel setTextColor:[UIColor grayColor]];
        [postTitleLabel setText:@"Posts"];
        
        [self.socialPanel addSubview:self.postsLabel];
        [self.socialPanel addSubview:postTitleLabel];
        
        //Create and add the profile views.
        self.profileViewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, -5, 50, 50)];
        [self.profileViewsLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [self.profileViewsLabel setTextColor:[UIColor grayColor]];
        [self.profileViewsLabel setText:@"1,293"];
        
        //20 165 254
        
        //Add profile views title.
        UILabel *profileViewsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 50, 50)];
        [profileViewsTitleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:8]];
        [profileViewsTitleLabel setTextColor:[UIColor grayColor]];
        [profileViewsTitleLabel setText:@"Profile Views"];
        
        [self.socialPanel addSubview:self.profileViewsLabel];
        [self.socialPanel addSubview:profileViewsTitleLabel];
        
        //Create and add the number of friends.
        self.friendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, -5, 50, 50)];
        [self.friendsLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [self.friendsLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"colour_of_selected_profile_element"]]];
        [self.friendsLabel setText:@"855"];
        
        //Add number of friends title.
        UILabel *friendsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 50, 50)];
        [friendsTitleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:8]];
        [friendsTitleLabel setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"colour_of_selected_profile_element"]]];
        [friendsTitleLabel setText:@"Friends"];
        //6 183 248
        
        [self.socialPanel addSubview:self.friendsLabel];
        [self.socialPanel addSubview:friendsTitleLabel];

        
        //Create and add the number of rewards.
        self.rewardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, -5, 50, 50)];
        [self.rewardsLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [self.rewardsLabel setTextColor:[UIColor grayColor]];
        [self.rewardsLabel setText:@"52"];
        
        //Add number of rewards.
        UILabel *rewardsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 10, 50, 50)];
        [rewardsTitleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:8]];
        [rewardsTitleLabel setTextColor:[UIColor grayColor]];
        [rewardsTitleLabel setText:@"Rewards"];
        
        [self.socialPanel addSubview:self.rewardsLabel];
        [self.socialPanel addSubview:rewardsTitleLabel];
        
        
        
        [self addSubview:self.socialPanel];
        
        
        
        //Create the profile image view.
        UIImage *profileImage = [UIImage imageNamed:@"avatar_big"];
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 120, 90, 90)];
        
        [self.profileImageView setImage:profileImage];
        
        [self addSubview:self.profileImageView];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
