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

float const kButtonsViewHeight = 40;
float const kContentLabelMaxWidth = 240;
float const kViewTopPadding = 10;
float const kViewBottomPadding = 10;
float const kContentLabelBottomMargin = 7;

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
    // configure elements' frames
    CGSize contentSize = [NotificationCell getContentLabelSizeForContent:[notification notificationTypeDescription]];
    float contentHeight = contentSize.height;

    NSString* currentIdentifier = [self valueForKey:@"_reuseIdentifier"];
    
    if(notification.seen)
    {
        //Change the colour of the cell.
        self.incomingNotification.hidden = YES;
    }
    else
    {
        self.incomingNotification.hidden = NO;
    }
    
    if([currentIdentifier isEqualToString:kGLPNotificationCell])
    {
        CGRectSetH(self.contentLabel, contentHeight);
        CGRectSetY(self.time, self.contentLabel.frame.origin.y + contentHeight + kContentLabelBottomMargin);
    }
    
    if([notification hasAction]) {
        
        //If the user is already in user's contacts list then don't show the buttonsView.
        if([[ContactsManager sharedInstance] isUserContactWithId:notification.user.remoteKey])
        {
            [self setButtonsViewHiddenWithIdentifier:currentIdentifier];
            [notification alreadyContacts];
        }
        else
        {
            self.buttonsView.hidden = NO;
//            if([currentIdentifier isEqualToString:kGLPNotificationCell])
//            {
                CGRectSetY(self.buttonsView, self.time.frame.origin.y + self.time.frame.size.height);
                CGRectSetH(self.contentView, self.buttonsView.frame.origin.y + self.buttonsView.frame.size.height + kViewBottomPadding);
//            }

            // wtf again is that
            self.acceptButton.tag = self.ignoreButton.tag = notification.user.remoteKey;
            
            [self configureButtonsView];
        }

    }else if([notification hasActionNewFriends])
    {
        //Appear the second image.
        self.myImage.hidden = NO;
        [self.myImage setImageWithURL:[NSURL URLWithString:[SessionManager sharedInstance].user.profileImageUrl] placeholderImage:nil];
        
        //Reorder main image.
        CGRectSetX(self.image, 5.0);
    }
    else {
        [self setButtonsViewHiddenWithIdentifier:currentIdentifier];
    }
    
    self.contentLabel.text = [notification notificationTypeDescription];
//    self.time.text = [notification.date description];
    self.time.text = [notification.date timeAgo];
    
    [ShapeFormatterHelper setRoundedView:self.image toDiameter:self.image.frame.size.height];
    [self.image setImageWithURL:[NSURL URLWithString:notification.user.profileImageUrl] placeholderImage:nil];
}

- (void)acceptButtonClick
{
    [_delegate notificationCell:self acceptButtonClickForNotification:_notification];
}

- (void)ignoreButtonClick
{
    [_delegate notificationCell:self ignoreButtonClickForNotification:_notification];
}

-(void)setButtonsViewHiddenWithIdentifier:(NSString*)currentIdentifier
{
    self.buttonsView.hidden = YES;
    if([currentIdentifier isEqualToString:kGLPNotificationCell])
    {
        CGRectSetH(self.contentView, self.time.frame.origin.y + self.time.frame.size.height + kViewBottomPadding);
    }
}

+ (CGSize)getContentLabelSizeForContent:(NSString *)content
{
    CGSize maximumLabelSize = CGSizeMake(kContentLabelMaxWidth, FLT_MAX);
    
    return [content sizeWithFont: [UIFont systemFontOfSize:16.0] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
}

+ (CGFloat)getCellHeightForNotification:(GLPNotification *)notification
{
    // initial height with all heights and margins of other elements
    float height = kViewTopPadding + kViewBottomPadding + kContentLabelBottomMargin;
    
    // dynamic label
    height += [NotificationCell getContentLabelSizeForContent:[notification notificationTypeDescription]].height;
    
    // buttons view height
    if([notification hasAction]) {
        height += kButtonsViewHeight;
    }
    
    return height;
}

@end
