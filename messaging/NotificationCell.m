//
//  NotificationCell.m
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NotificationCell.h"
#import "NSDate+TimeAgo.h"
#import "ContactsManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SessionManager.h"
#import "ShapeFormatterHelper.h"

@interface NotificationCell()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *ignoreButton;
@property (weak, nonatomic) IBOutlet UIImageView *incomingNotification;
@property (weak, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) IBOutlet UIImageView *friendsLinkImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pictoImageView;

@property (strong, nonatomic) GLPNotification *notification;

@end


@implementation NotificationCell

@synthesize notification=_notification;
@synthesize delegate=_delegate;

NSString * const kGLPNotificationCell = @"GLPNotificationCell";
NSString * const kGLPNotCell = @"GLPNotCell";



float const kViewTopPadding = 10;
float const kViewBottomPadding = 10;
float const kContentLabelBottomMargin = 7;

// views sizes
float const kProfileImageSize = 40;
float const kTwoProfileImagesWidth = 70;
float const kContentLabelNoPictoMaxWidth = 212;
float const kContentLabelWithPictoMaxWidth = 182;
float const kPictoImageSize = 13;
float const kButtonsViewHeight = 32;

// vertical margins
float const kMarginBetweenTopAndContent = 10;
float const kMarginBetweenContentAndButtonsView = 9;
float const kMarginBetweenContentAndBottom = 10;

// horizontal margins
float const kMarginBetweenProfileImageAndContent = 15;
float const kMarginBetweenContentAndPictoImage = 8;
float const kMarginBetweenBorderAndContent = 15;

- (void)awakeFromNib
{
    
}

- (void)configureButtonsView
{
    [self.acceptButton addTarget:self action:@selector(acceptButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.ignoreButton addTarget:self action:@selector(ignoreButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateWithNotification:(GLPNotification *)notification
{
    _notification = notification;
    
    // update content view height
    CGRectSetH(self.contentView, [NotificationCell getCellHeightForNotification:notification]);
    
    // common stuff
    self.contentLabel.text = [notification notificationTypeDescription];
    
    [ShapeFormatterHelper setRoundedView:self.image toDiameter:self.image.frame.size.height];
    [self.image setImageWithURL:[NSURL URLWithString:notification.user.profileImageUrl] placeholderImage:nil];
    
    // center content label vertically regarding the image
    CGSize contentLabelSize = [NotificationCell getContentLabelSizeForContent:self.contentLabel.text forNotification:notification];
    contentLabelSize.width = [NotificationCell getContentLabelMaxWidthforNotification:notification];
    CGRectSetWH(self.contentLabel, contentLabelSize.width, contentLabelSize.height);
    
    // content label small enough to fit vertically inside image height
    // otherwise, start aligned on top with image
    float margin = 0;
    if(self.image.frame.size.height > contentLabelSize.height) {
        margin = (self.image.frame.size.height - contentLabelSize.height) / 2;
    }
    
    CGRectSetY(self.contentLabel, self.image.frame.origin.y + margin);
    
    // defaults settings for views
    CGRectSetX(self.contentLabel, kMarginBetweenBorderAndContent + kProfileImageSize + kMarginBetweenProfileImageAndContent);
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    
    self.buttonsView.hidden = YES;
    self.friendsLinkImageView.hidden = YES;
    self.myImage.hidden = YES;
    self.pictoImageView.hidden = YES;
    
    // added you event
    if(notification.notificationType == kGLPNotificationTypeAddedYou)
    {
        self.buttonsView.hidden = NO;
        
        float biggestView = (self.image.frame.size.height >= self.contentLabel.frame.size.height) ? CGRectGetMaxY(self.image.frame) : CGRectGetMaxY(self.contentLabel.frame);
        CGRectSetY(self.buttonsView, biggestView + kMarginBetweenContentAndButtonsView);
        
        [self configureButtonsView];
        
    }
    
    else if(notification.notificationType == kGLPNotificationTypeAcceptedYou)
    {
        self.friendsLinkImageView.hidden = NO;
        self.myImage.hidden = NO;
        
        NSString *currentProfile = [SessionManager sharedInstance].user.profileImageUrl;
        [ShapeFormatterHelper setRoundedView:self.myImage toDiameter:self.myImage.frame.size.height];
        [self.myImage setImageWithURL:[NSURL URLWithString:currentProfile] placeholderImage:nil];
        
        CGRectSetX(self.contentLabel, kMarginBetweenBorderAndContent + kTwoProfileImagesWidth + kMarginBetweenProfileImageAndContent);
        self.contentLabel.textAlignment = NSTextAlignmentRight;
        
    } else if(notification.notificationType == kGLPNotificationTypeCommented ||
              notification.notificationType == kGLPNotificationTypeLiked)
    {
        
        self.pictoImageView.hidden = NO;
        
        NSString *imageName = notification.notificationType == kGLPNotificationTypeLiked ? @"internal_notification_cell_liked" : @"internal_notification_cell_commented";
        self.pictoImageView.image = [UIImage imageNamed:imageName];
    }
//    else if (notification.notificationType == kGLPNotificationTypeAddedGroup)
//    {
//        self.pictoImageView.hidden = YES;
//    }
    
}

- (void)acceptButtonClick
{
    [_delegate notificationCell:self acceptButtonClickForNotification:_notification];
}

- (void)ignoreButtonClick
{
    [_delegate notificationCell:self ignoreButtonClickForNotification:_notification];
}

+ (float)getContentLabelMaxWidthforNotification:(GLPNotification *)notification
{
    // max width of content label depends of the type
    float maxW = 320 - (kMarginBetweenBorderAndContent * 2);
    
    // two profile images
    if(notification.notificationType == kGLPNotificationTypeAcceptedYou) {
        maxW = maxW - kMarginBetweenProfileImageAndContent - kTwoProfileImagesWidth;
    }
    // contact request
    else if(notification.notificationType == kGLPNotificationTypeAddedYou) {
        maxW = maxW - kMarginBetweenProfileImageAndContent - kProfileImageSize;
    }
    // like or post
    else {
        maxW = maxW - kMarginBetweenProfileImageAndContent - kProfileImageSize - kPictoImageSize - kMarginBetweenContentAndPictoImage;
    }

    return maxW;
}

+ (CGSize)getContentLabelSizeForContent:(NSString *)content forNotification:(GLPNotification *)notification
{
    float maxW = [NotificationCell getContentLabelMaxWidthforNotification:notification];
    
    CGSize maximumLabelSize = CGSizeMake(maxW, FLT_MAX);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0];
    return [content sizeWithFont: font constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
}

+ (CGFloat)getCellHeightForNotification:(GLPNotification *)notification
{
    // initial height with all heights and margins of other elements
    float height = kMarginBetweenTopAndContent + kMarginBetweenContentAndBottom;
    
    // dynamic label
    float labelHeight = [NotificationCell getContentLabelSizeForContent:[notification notificationTypeDescription] forNotification:notification].height;
    
    float biggest = (labelHeight > kProfileImageSize) ? labelHeight : kProfileImageSize;
    height += biggest;
    
    if(notification.notificationType == kGLPNotificationTypeAddedYou) {
        height += kButtonsViewHeight + kMarginBetweenContentAndButtonsView;
    }
    
    return height;
}

@end
