//
//  GLPPopUpDialogViewController.h
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPopUpDialogViewController.h"

@class GLPPost;


@protocol GLPAttendingPopUpViewControllerDelegate <NSObject>

@required
- (void)showAttendees;
- (void)addEventToCalendar;

@end

@interface GLPAttendingPopUpViewController : GLPPopUpDialogViewController

@property (weak, nonatomic) UIViewController<GLPAttendingPopUpViewControllerDelegate> *delegate;

- (void)setEventPost:(GLPPost *)eventPost;

@end
