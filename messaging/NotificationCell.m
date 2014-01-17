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


@implementation NotificationCell

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


//- (void)updateWithNotification:(GLPNotification *)notification withViewController:(NotificationsViewController*) controller
- (void)updateWithNotification:(GLPNotification *)notification withViewController:(UIViewController*) controller
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

            self.acceptButton.tag = self.ignoreButton.tag = notification.user.remoteKey;
            
            [self.acceptButton addTarget:controller action:@selector(acceptContact:) forControlEvents:UIControlEventTouchUpInside];
            [self.ignoreButton addTarget:controller action:@selector(ignoreContact:) forControlEvents:UIControlEventTouchUpInside];
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
