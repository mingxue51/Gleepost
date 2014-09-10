//
//  GLPNotificationCell.h
//  Gleepost
//
//  Created by Σιλουανός on 9/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPImageView.h"

@class GLPNotification;

@interface GLPNotificationCell : UITableViewCell

extern const float NOTIFICATION_CELL_HEIGHT;

@property (weak, nonatomic) UIViewController <GLPImageViewDelegate> *delegate;

- (void)setNotification:(GLPNotification *)notification;
+ (CGFloat)getCellHeightForNotification:(GLPNotification *)notification;

@end
