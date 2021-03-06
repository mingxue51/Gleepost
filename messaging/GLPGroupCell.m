//
//  GLPGroupCell.m
//  Gleepost
//
//  Created by Silouanos on 23/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPGroupCell.h"
#import "ShapeFormatterHelper.h"
#import "GLPGroup.h"
#import "GLPImageHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GLPLiveGroupManager.h"
#import "GLPCustomProgressView.h"
#import "GLPiOSSupportHelper.h"
#import "GLPLiveGroupConversationsManager.h"
#import "GLPConversation.h"

@interface GLPGroupCell ()

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UIImageView *groupOverlayImageView;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIView *notificationsView;
@property (weak, nonatomic) IBOutlet UILabel *notificationsLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTopDistance;
@property (weak, nonatomic) IBOutlet UIView *pendingView;
@property (weak, nonatomic) IBOutlet UILabel *pendingGroupNameLabel;
@property (weak, nonatomic) IBOutlet GLPCustomProgressView *uploadingImageProgressBar;

/** Constants strings. */

@property (strong, nonatomic, readonly) NSString *groupString;
@property (strong, nonatomic, readonly) NSString *membersString;
@property (strong, nonatomic, readonly) NSString *memberString;

@property (strong, nonatomic) GLPGroup *groupData;



@end

@implementation GLPGroupCell

- (void)awakeFromNib
{
    [self configureObjects];
    [self formatElements];
    [self configureCell];
}

#pragma mark - Configuration

- (void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:_groupImageView andValue:3];
    [ShapeFormatterHelper setCornerRadiusWithView:_groupOverlayImageView andValue:3];
}

- (void)configureObjects
{
    _membersString = @"MEMBERS";
    _groupString = @"GROUP";
    _memberString = @"MEMBER";
}

- (void)configureCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Accessors

- (UIImage *)groupImage
{
    return _groupImageView.image;
}

#pragma mark - Modifiers

- (void)setGroupData:(GLPGroup *)groupData
{
    _groupData = groupData;
    [self configureNameText];
    [self setGroupImage];
    [self configureUnreadPostsBadge];
    [self configureVisibilityOfPendingView];
    [self configureNSNotification];
    [self configureInformationLabel];
}

- (void)configureNameText
{
    [_groupNameLabel setText:_groupData.name];
    [_pendingGroupNameLabel setText:_groupData.name];
    [_nameLabelHeight setConstant:[self getNametLabelHeight]];
}

- (void)configureInformationLabel
{
    [_informationLabel setText:[NSString stringWithFormat:@"%@ %@ • %ld %@",[[_groupData privacyToString] uppercaseString], _groupString, (long)_groupData.membersCount, (_groupData.membersCount == 1) ? _memberString : _membersString]];
}

- (void)setGroupImage
{
    if(_groupData.sendStatus == kSendStatusLocal)
    {
//        [_groupImageView setImage:_groupData.pendingImage];
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[_groupData generatePendingIdentifier]];
        
        if(image)
        {
            [_groupImageView setImage: image];
        }
        else
        {
            [_groupImageView setImage:[GLPImageHelper placeholderGroupImage]];
        }
        
        return;
    }
    
    if([_groupData.groupImageUrl isEqualToString:@""] || !_groupData.groupImageUrl)
    {
        [_groupImageView setImage:[GLPImageHelper placeholderGroupImage]];
    }
    else
    {
        [_groupImageView sd_setImageWithURL:[NSURL URLWithString:_groupData.groupImageUrl] placeholderImage:[GLPImageHelper placeholderGroupImage] options:SDWebImageContinueInBackground];
    }
}

- (void)configureVisibilityOfPendingView
{
    if(_groupData.sendStatus == kSendStatusLocal)
    {
        [self showPendingView];
    }
    else
    {
        [self hidePendingView];
    }
}

- (void)configureNSNotification
{
    if(_groupData.sendStatus == kSendStatusLocal)
    {
        [self updateProgressBarIfNeeded];
        [self registerProgressViewNotification];
    }
    else
    {
        [self removeProgressViewNotification];
    }
}

- (void)showPendingView
{
    //Fixing an issue caused between iOS7 and iOS8 with positioning with progress view. (don't know why)
    if(![GLPiOSSupportHelper isIOS7] && ![GLPiOSSupportHelper isIOS6])
    {
        [_progressViewTopDistance setConstant:20];
    }
    
    [_pendingView setHidden:NO];
    [self setHiddenNormalView:YES];
}

- (void)hidePendingView
{
    [_pendingView setHidden:YES];
    [self setHiddenNormalView:NO];
}

- (void)setHiddenNormalView:(BOOL)hidden
{
    [_groupNameLabel setHidden:hidden];
    [_informationLabel setHidden:hidden];
    [_arrowImageView setHidden:hidden];
}

- (void)configureUnreadPostsBadge
{
    NSInteger count = [[GLPLiveGroupManager sharedInstance] numberOfUnseenPostsWithGroup:_groupData];
    
    GLPConversation *conversation = [[GLPLiveGroupConversationsManager sharedInstance] findByRemoteKey:_groupData.conversationRemoteKey];
    
    count+=conversation.unreadMessagesCount;
    
    if(count != 0)
    {
        [_notificationsView setHidden:NO];
        [_notificationsLabel setText:[NSString stringWithFormat:@"%@", @(count)]];
    }
    else
    {
        [_notificationsView setHidden:YES];
    }
}

- (CGFloat)getNametLabelHeight
{
    if(!_groupData.name)
    {
        return 0.0;
    }

    CGSize size = [_groupNameLabel sizeThatFits:(CGSize){230.0, 50.0}];
    return size.height;
}

#pragma mark - NSNotifications

- (void)registerProgressViewNotification
{
    DDLogDebug(@"GLPGroupCell registerProgressViewNotification %@", [self generateNewGroupImageProgressNotification]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressBar:) name:[self generateNewGroupImageProgressNotification] object:nil];
}

- (void)removeProgressViewNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:[self generateNewGroupImageProgressNotification]];
}

- (NSString *)generateNewGroupImageProgressNotification
{
    return [NSString stringWithFormat:@"%ld_%@", (long)_groupData.key, GLPNOTIFICATION_NEW_GROUP_IMAGE_PROGRESS];
}

#pragma mark - Progress bar

- (void)updateProgressBar:(NSNotification *)notification
{
    float uploadedProgress = [notification.userInfo[@"uploaded_progress"] floatValue];
    [_uploadingImageProgressBar setProgress:uploadedProgress];
}

- (void)updateProgressBarIfNeeded
{
    CGFloat currentProgress = [[GLPLiveGroupManager sharedInstance] uploadingGroupProgress];
    
    if(currentProgress == -1.0)
    {
        return;
    }
    
    [_uploadingImageProgressBar setProgress:currentProgress];
}

#pragma mark - Static

+ (CGFloat)height
{
    return [GLPiOSSupportHelper screenWidth] * 0.42;
}

+ (NSString *)cellIdentifier
{
    return @"GLPGroupCell";
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
