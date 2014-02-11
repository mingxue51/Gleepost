//
//  NotificationCell.h
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPNotification.h"
#import "NotificationsViewController.h"

@class NotificationCell;


@protocol GLPNotificationCellDelegate <NSObject>

- (void)notificationCell:(NotificationCell *)cell acceptButtonClickForNotification:(GLPNotification *)notification;
- (void)notificationCell:(NotificationCell *)cell ignoreButtonClickForNotification:(GLPNotification *)notification;

@end


@interface NotificationCell : UITableViewCell

extern NSString * const kGLPNotificationCell;
extern NSString* const kGLPNotCell;

@property (weak, nonatomic) id<GLPNotificationCellDelegate> delegate;

+ (CGSize)getContentLabelSizeForContent:(NSString *)content forNotification:(GLPNotification *)notification;
+ (CGFloat)getCellHeightForNotification:(GLPNotification *)notification;

- (void)updateWithNotification:(GLPNotification *)notification;

@end
