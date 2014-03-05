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

-(void)setDelegate:(UIViewController<GroupCreatedDelegate> *)delegate;

@end
