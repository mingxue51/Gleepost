//
//  CreateNewGroupCell.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsViewController.h"
#import "GroupCreatedDelegate.h"

@interface CreateNewGroupCell : UITableViewCell <UIAlertViewDelegate>

extern const float NEW_GROUP_CELL_HEIGHT;

-(void)setDelegate:(UIViewController<GroupCreatedDelegate> *)delegate;

@end
