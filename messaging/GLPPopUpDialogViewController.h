//
//  GLPPopUpDialogViewController.h
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPPopUpDialogViewControllerDelegate <NSObject>

@required
- (void)showAttendees;
- (void)addEventToCalendar;

@end

@interface GLPPopUpDialogViewController : UIViewController

@property (weak, nonatomic) UIViewController<GLPPopUpDialogViewControllerDelegate> *delegate;

- (void)setTopImage:(UIImage *)topImage;

@end
