//
//  GLPPublicGroupPopUpViewController.h
//  Gleepost
//
//  Created by Silouanos on 27/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPopUpDialogViewController.h"

@protocol GLPPublicGroupPopUpViewControllerDelegate <NSObject>

- (void)showMembers;
- (void)invitePeople;
- (void)dismissNavController;

@end


@interface GLPPublicGroupPopUpViewController : GLPPopUpDialogViewController

@property (weak, nonatomic) UIViewController <GLPPublicGroupPopUpViewControllerDelegate> *delegate;

- (void)setGroupImage:(UIImage *)groupImage;

@end
