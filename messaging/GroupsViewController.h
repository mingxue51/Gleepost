//
//  ContactsViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 20/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupCreatedDelegate.h"
#import "GroupDeletedDelegate.h"

@interface GroupsViewController : UITableViewController <GroupCreatedDelegate, GroupDeletedDelegate>

@property (nonatomic, strong) NSMutableArray *sections;

@end
