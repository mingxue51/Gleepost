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

@property (readonly, nonatomic) GLPProfileViewController *delegate;


-(void)setDelegate:(GLPProfileViewController *)delegate;
@end
