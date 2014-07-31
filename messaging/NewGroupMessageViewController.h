//
//  NewGroupMessageViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 2/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPCheckNameCell.h"
#import "GLPSelectUsersViewController.h"

@interface NewGroupMessageViewController : GLPSelectUsersViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, GLPCheckNameCellDelegate, GLPSelectUsersViewControllerDelegate>

@end
