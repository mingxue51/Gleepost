//
//  ProfileTwoButtonsTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPProfileViewController.h"
#import "ButtonNavigationDelegate.h"

@interface ProfileTwoButtonsTableViewCell : UITableViewCell

extern const float TWO_BUTTONS_CELL_HEIGHT;

@property (weak, nonatomic) IBOutlet UIImageView *notificationsBubbleImageView;

@property (readonly, nonatomic) UIViewController<ButtonNavigationDelegate> *delegate;


-(void)setDelegate:(UIViewController<ButtonNavigationDelegate> *)delegate;
@end
