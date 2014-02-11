//
//  ProfileTwoButtonsTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPProfileViewController.h"


@interface ProfileTwoButtonsTableViewCell : UITableViewCell

extern const float TWO_BUTTONS_CELL_HEIGHT;

@property (weak, nonatomic) IBOutlet UIImageView *notificationsBubbleImageView;

@property (readonly, nonatomic) GLPProfileViewController *delegate;


-(void)setDelegate:(GLPProfileViewController *)delegate;
@end
