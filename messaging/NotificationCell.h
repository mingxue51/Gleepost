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

@interface NotificationCell : UITableViewCell

extern NSString * const kGLPNotificationCell;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *ignoreButton;
@property (weak, nonatomic) IBOutlet UIImageView *incomingNotification;

+ (CGSize)getContentLabelSizeForContent:(NSString *)content;
+ (CGFloat)getCellHeightForNotification:(GLPNotification *)notification;

- (void)updateWithNotification:(GLPNotification *)notification withViewController:(UIViewController*) controller;

@end
