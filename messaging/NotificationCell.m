//
//  NotificationCell.m
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NotificationCell.h"
#import "NSDate+TimeAgo.h"

@implementation NotificationCell

NSString * const kGLPNotificationCell = @"GLPNotificationCell";

float const kButtonsViewHeight = 40;
float const kContentLabelMaxWidth = 240;
float const kViewTopPadding = 10;
float const kViewBottomPadding = 10;
float const kContentLabelBottomMargin = 7;

- (void)awakeFromNib
{
    
}


- (void)updateWithNotification:(GLPNotification *)notification withViewController:(NotificationsViewController*) controller
{    
    // configure elements' frames
    CGSize contentSize = [NotificationCell getContentLabelSizeForContent:[notification notificationTypeDescription]];
    float contentHeight = contentSize.height;

    if(notification.seen)
    {
        //Change the colour of the cell.
        self.incomingNotification.hidden = YES;
    }
    else
    {
        self.incomingNotification.hidden = NO;
    }
    
    
    CGRectSetH(self.contentLabel, contentHeight);
    CGRectSetY(self.time, self.contentLabel.frame.origin.y + contentHeight + kContentLabelBottomMargin);
    
    if([notification hasAction]) {
        self.buttonsView.hidden = NO;
        CGRectSetY(self.buttonsView, self.time.frame.origin.y + self.time.frame.size.height);
        CGRectSetH(self.contentView, self.buttonsView.frame.origin.y + self.buttonsView.frame.size.height + kViewBottomPadding);
        self.acceptButton.tag = self.ignoreButton.tag = notification.user.remoteKey;
        
        [self.acceptButton addTarget:controller action:@selector(acceptContact:) forControlEvents:UIControlEventTouchUpInside];
        [self.ignoreButton addTarget:controller action:@selector(ignoreContact:) forControlEvents:UIControlEventTouchUpInside];

    } else {
        self.buttonsView.hidden = YES;
        CGRectSetH(self.contentView, self.time.frame.origin.y + self.time.frame.size.height + kViewBottomPadding);
    }
    
    self.contentLabel.text = [notification notificationTypeDescription];
//    self.time.text = [notification.date description];
    self.time.text = [notification.date timeAgo];
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
