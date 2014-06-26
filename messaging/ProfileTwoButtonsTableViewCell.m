//
//  ProfileTwoButtonsTableViewCell.m
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ProfileTwoButtonsTableViewCell.h"
#import "GroupViewController.h"

@interface ProfileTwoButtonsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *postsLine;

@property (weak, nonatomic) IBOutlet UIImageView *settingsLine;
@property (weak, nonatomic) IBOutlet UIButton *myPostsBtn;
@property (weak, nonatomic) IBOutlet UIButton *notificationsBtn;
@property (weak, nonatomic) IBOutlet UILabel *notificationsCountLbl;


@property (assign, nonatomic) BOOL isProfileViewController;

@end

@implementation ProfileTwoButtonsTableViewCell

@synthesize notificationsBubbleImageView=_notificationsBubbleImageView;

const float TWO_BUTTONS_CELL_HEIGHT = 50.0f;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {

    }
    
    return self;
}

#pragma mark - Group methods

//TODO: Call that in the future when there will be a need for introducing buttons in group.

//-(void)configViewForGroups
//{
//    [self showGroupButtonsPostsSelected];
//}

-(void)setDelegate:(UIViewController<ButtonNavigationDelegate> *)delegate fromPushNotification:(BOOL)push
{
    if([delegate isKindOfClass:[GLPProfileViewController class]])
    {
        _isProfileViewController = YES;
        
        if(push)
        {
//            [self viewSettingsButton];

            #warning test that if works.
            
            [self viewSettings:nil];
        }
    }
    else if([delegate isKindOfClass:[GroupViewController class]])
    {
        _isProfileViewController = NO;
        [_notificationsBubbleImageView setHidden:YES];
        [_notificationsCountLbl setHidden:YES];
        
        if(!_delegate)
        {
            [self showGroupButtonsPostsSelected];
        }
        
    }
    
    _delegate = delegate;
}

#pragma mark - Selectors

- (IBAction)viewPosts:(id)sender
{
    [self setGrayToNavigators];
    
    [self setGreenToNavigator:self.postsLine];
    
    if(_isProfileViewController)
    {
        [self showProfileButtonsPostsSelected];
    }
    else
    {
        [self showGroupButtonsPostsSelected];
    }
    

    [_delegate viewSectionWithId:kGLPPosts];
}


- (IBAction)viewSettings:(id)sender
{
    [self setGrayToNavigators];
    
    [self setGreenToNavigator:self.settingsLine];

    
    if(_isProfileViewController)
    {
        [self showProfileButtonsNotificationsSelected];
        [_delegate viewSectionWithId:kGLPNotifications];

    }
    else
    {
        [_delegate viewSectionWithId:kGLPMembers];

//        [self showGroupButtonsMembersSelected];
    }
}

//-(void)viewSettingsButton
//{
//    [self setGrayToNavigators];
//    
//    [self setGreenToNavigator:self.settingsLine];
//    
//    
//    if(_isProfileViewController)
//    {
//        [self showProfileButtonsNotificationsSelected];
//        [_delegate viewSectionWithId:kGLPSettings];
//        
//    }
//    else
//    {
//        [_delegate viewSectionWithId:kGLPSettings];
//        
//        //        [self showGroupButtonsMembersSelected];
//    }
//}


-(void)setGreenToNavigator:(UIImageView*)navigator
{
    [navigator setImage:[UIImage imageNamed:@"active_tab"]];
}

-(void)setGrayToNavigators
{
    [self.settingsLine setImage:[UIImage imageNamed:@"idle_tab"]];
    
    [self.postsLine setImage:[UIImage imageNamed:@"idle_tab"]];
}

-(void)showGroupButtonsPostsSelected
{
    [_myPostsBtn setImage:[UIImage imageNamed:@"group_posts"] forState:UIControlStateNormal];
    [_notificationsBtn setImage: [UIImage imageNamed:@"members"] forState:UIControlStateNormal];
}

-(void)showGroupButtonsMembersSelected
{
    [_myPostsBtn setImage:[UIImage imageNamed:@"group_posts"] forState:UIControlStateNormal];
    [_notificationsBtn setImage:[UIImage imageNamed:@"members_selected"] forState:UIControlStateNormal];
}

-(void)showProfileButtonsPostsSelected
{
    [_myPostsBtn setImage:[UIImage imageNamed:@"mypost_btn_selected"] forState:UIControlStateNormal];
    [_notificationsBtn setImage:[UIImage imageNamed:@"notification_btn"] forState:UIControlStateNormal];
}

-(void)showProfileButtonsNotificationsSelected
{
    [_myPostsBtn setImage:[UIImage imageNamed:@"mypost_btn"] forState:UIControlStateNormal];
    [_notificationsBtn setImage:[UIImage imageNamed:@"notification_btn_selected"] forState:UIControlStateNormal];
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

#pragma mark - Modifiers

-(void)showNotificationBubbleWithNotificationCount:(int)notificationCount
{
    [_notificationsBubbleImageView setHidden:NO];
    [_notificationsCountLbl setHidden:NO];
    [_notificationsCountLbl setText:[NSString stringWithFormat:@"%d", notificationCount]];
}

-(void)hideNotificationBubble
{
    [_notificationsBubbleImageView setHidden:YES];
    [_notificationsCountLbl setHidden:YES];

}

@end
