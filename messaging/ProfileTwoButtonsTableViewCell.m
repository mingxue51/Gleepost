//
//  ProfileTwoButtonsTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileTwoButtonsTableViewCell.h"

@interface ProfileTwoButtonsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *postsLine;

@property (weak, nonatomic) IBOutlet UIImageView *settingsLine;
@property (weak, nonatomic) IBOutlet UIButton *myPostsBtn;
@property (weak, nonatomic) IBOutlet UIButton *notificationsBtn;

@end

@implementation ProfileTwoButtonsTableViewCell

@synthesize notificationsBubbleImageView=_notificationsBubbleImageView;

const NSString *POST_IMAGE_SELECTED = @"mypost_btn_selected";
const NSString *POST_IMAGE = @"mypost_btn";
const NSString *NOTIFICATIONS_IMAGE_SELECTED = @"notification_btn_selected";
const NSString *NOTIFICATIONS_IMAGE = @"notification_btn";
const float TWO_BUTTONS_CELL_HEIGHT = 50.0f;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {

    }
    
    return self;
}

-(void)setDelegate:(GLPProfileViewController *)delegate
{
    _delegate = delegate;
}

- (IBAction)viewPosts:(id)sender
{
    [self setGrayToNavigators];
    
    [self setGreenToNavigator:self.postsLine];
    
    
    UIButton * viewPost = (UIButton*)sender;
    
    [viewPost setImage: [UIImage imageNamed:@"mypost_btn_selected"] forState:UIControlStateNormal];
    
    [_notificationsBtn setImage: [UIImage imageNamed:@"notification_btn"] forState:UIControlStateNormal];
    
    
    [_delegate viewSectionWithId:kGLPPosts];
}


- (IBAction)viewSettings:(id)sender
{
    
    [self setGrayToNavigators];
    
    [self setGreenToNavigator:self.settingsLine];
    
    UIButton * viewPost = (UIButton*)sender;
    
    [viewPost setImage: [UIImage imageNamed:@"notification_btn_selected"] forState:UIControlStateNormal];
    
    [_myPostsBtn setImage: [UIImage imageNamed:@"mypost_btn"] forState:UIControlStateNormal];
    
    
    [_delegate viewSectionWithId:kGLPSettings];
}


-(void)setGreenToNavigator:(UIImageView*)navigator
{
    [navigator setImage:[UIImage imageNamed:@"active_tab"]];
}

-(void)setGrayToNavigators
{
    [self.settingsLine setImage:[UIImage imageNamed:@"idle_tab"]];
    
    [self.postsLine setImage:[UIImage imageNamed:@"idle_tab"]];
}

-(void)showAllLines
{
    [self.settingsLine setHidden:NO];
    [self.postsLine setHidden:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
