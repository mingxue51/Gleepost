//
//  ProfileTopViewCell.m
//  Gleepost
//
//  Created by Σιλουανός on 25/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ProfileTopViewCell.h"
#import "GLPUser.h"

@interface ProfileTopViewCell ()

@property (strong, nonatomic) GLPUser *userData;

@property (weak, nonatomic) IBOutlet GLPSegmentView *segmentView;

@property (weak, nonatomic) IBOutlet UIImageView *notificationImageView;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;

@end

@implementation ProfileTopViewCell

const float PROFILE_TOP_VIEW_HEIGHT = 245.0;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}

- (void)setUserData:(GLPUser *)userData
{
    _userData = userData;
    
    [super setImageWithUrl:userData.profileImageUrl];
    
    [super setTitleWithString:userData.name];
    
    [super setSubtitleWithString:userData.networkName];
    
    [super setSmallSubtitleWithString:userData.personalMessage];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [super setSubClassdelegate:self];
    
    [self configureSegmentView];
    
    [_notificationLabel setHidden:YES];
    [_notificationImageView setHidden:YES];
}

#pragma mark - Configuration

- (void)configureSegmentView
{
    [self loadSegmentView];
}

- (void)loadSegmentView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPProfileSegmentView" owner:self options:nil];
    
    GLPSegmentView *view = [array lastObject];
    [view setDelegate:self];
    [view setRightButtonTitle:@"Notifications" andLeftButtonTitle:@"Posts"];
    
//    _segmentView = view;
    
    [_segmentView addSubview:view];
}

#pragma mark - Modifiers

-(void)showNotificationBubbleWithNotificationCount:(int)notificationCount
{
    [_notificationImageView setHidden:NO];
    [_notificationLabel setHidden:NO];
    [_notificationLabel setText:[NSString stringWithFormat:@"%d", notificationCount]];
}

-(void)hideNotificationBubble
{
    [_notificationImageView setHidden:YES];
    [_notificationLabel setHidden:YES];
}

- (void)comesFromPushNotification:(BOOL)fromPN
{
    //TODO: see if that works.
    
    if(fromPN)
    {
        [_segmentView selectRightButton];
    }
}

#pragma mark - GLPSegmentViewDelegate

- (void)segmentSwitched:(ButtonType)conversationsType
{
    [_delegate segmentSwitchedWithButtonType:conversationsType];
}

#pragma mark - TopTableViewCellDelegate

- (void)mainImageViewTouched
{
    [_delegate changeProfileImage:nil];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
