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
float const kPictoImageSize = 25;
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
    // update content view height
    CGRectSetH(self.contentView, [NotificationCell getCellHeightForNotification:notification]);
    
    // common stuff
    self.contentLabel.text = [notification notificationTypeDescription];
    
    [ShapeFormatterHelper setRoundedView:self.image toDiameter:self.image.frame.size.height];
    [self.image setImageWithURL:[NSURL URLWithString:notification.user.profileImageUrl] placeholderImage:nil];
    
    // center content label vertically regarding the image
    CGSize contentLabelSize = [NotificationCell getContentLabelSizeForContent:self.contentLabel.text forNotification:notification];
    CGRectSetWH(self.contentLabel, contentLabelSize.width, contentLabelSize.height);
    
    // content label small enough to fit vertically inside image height
    // otherwise, start aligned on top with image
    float margin = 0;
    if(self.image.frame.size.height < contentLabelSize.height) {
        margin = (self.image.frame.size.height - contentLabelSize.height) / 2;
    }
    
    CGRectSetY(self.contentLabel, self.image.frame.origin.y + margin);
    
    // default extra hidden
    self.buttonsView.hidden = YES;
    self.friendsLinkImageView.hidden = YES;
    self.myImage.hidden = YES;
    self.pictoImageView.hidden = YES;
    
    // added you event
    if(notification.notificationType == kGLPNotificationTypeAddedYou) {
        self.buttonsView.hidden = NO;
        
        float biggestView = (self.image.frame.size.height >= self.contentLabel.frame.size.height) ? GetViewYplusH(self.image) : GetViewYplusH(self.contentLabel);
        CGRectSetY(self.buttonsView, biggestView + kMarginBetweenContentAndButtonsView);
        
        [self configureButtonsView];
        
    }
    
    else if(notification.notificationType == kGLPNotificationTypeAcceptedYou) {
        self.friendsLinkImageView.hidden = NO;
        self.myImage.hidden = NO;
        
        [ShapeFormatterHelper setRoundedView:self.image toDiameter:self.image.frame.size.height];
        [self.image setImageWithURL:[NSURL URLWithString:[SessionManager sharedInstance].user.profileImageUrl] placeholderImage:nil];
        
        self.contentLabel.textAlignment = NSTextAlignmentRight;
    }
    

}

- (void)acceptButtonClick
{
    [_delegate notificationCell:self acceptButtonClickForNotification:_notification];
}

- (void)ignoreButtonClick
{
    [_delegate notificationCell:self ignoreButtonClickForNotification:_notification];
}

//-(void)setButtonsViewHiddenWithIdentifier:(NSString*)currentIdentifier
//{
//    self.buttonsView.hidden = YES;
//    if([currentIdentifier isEqualToString:kGLPNotificationCell])
//    {
//        CGRectSetH(self.contentView, self.time.frame.origin.y + self.time.frame.size.height + kViewBottomPadding);
//    }
//}

+ (CGSize)getContentLabelSizeForContent:(NSString *)content forNotification:(GLPNotification *)notification
{
    // max width of content label depends of the type
    float maxW = 320 - (kMarginBetweenBorderAndContent * 2);
    
    // two profile images
    if(notification.notificationType == kGLPNotificationTypeAcceptedYou) {
        maxW -= kMarginBetweenProfileImageAndContent - kTwoProfileImagesWidth;
    }
    // contact request
    else if(notification.notificationType == kGLPNotificationTypeAddedYou) {
        maxW -= kMarginBetweenProfileImageAndContent;
    }
    // like or post
    else {
        maxW -= kMarginBetweenProfileImageAndContent - kPictoImageSize - kMarginBetweenContentAndPictoImage;
    }
    
    CGSize maximumLabelSize = CGSizeMake(maxW, FLT_MAX);
    return [content sizeWithFont: [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
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
