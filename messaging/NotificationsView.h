//
//  NotificationsView.h
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPProfileViewController.h"

@interface NotificationsView : UIView

-(void)setDelegate:(GLPProfileViewController *)delegate;
-(void)updateNotificationsWithNumber:(int)notNumber;
-(void)hideNotifications;

@end
