//
//  PopUpNotificationsViewController.h
//  Gleepost
//
//  Created by Silouanos on 04/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"


@interface PopUpNotificationsViewController : UIViewController <UINavigationControllerDelegate>

@property (weak, nonatomic) ProfileViewController *delegate;
@property (assign, nonatomic) BOOL campusWallView;
@end
