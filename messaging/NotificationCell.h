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

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *ignoreButton;
@property (weak, nonatomic) IBOutlet UIImageView *incomingNotification;
@property (weak, nonatomic) IBOutlet UIImageView *myImage;

@property (weak, nonatomic) id<GLPNotificationCellDelegate> delegate;

+ (CGSize)getContentLabelSizeForContent:(NSString *)content;
+ (CGFloat)getCellHeightForNotification:(GLPNotification *)notification;

- (void)updateWithNotification:(GLPNotification *)notification;

@end
