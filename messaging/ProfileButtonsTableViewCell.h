//
//  ProfileButtonsTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPrivateProfileViewController.h"

@interface ProfileButtonsTableViewCell : UITableViewCell

extern const float BUTTONS_CELL_HEIGHT;


@property (readonly, nonatomic) GLPPrivateProfileViewController *delegate;


-(void)setDelegate:(GLPPrivateProfileViewController *)delegate;

@end
