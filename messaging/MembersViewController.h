//
//  MembersViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 8/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPGroup.h"

@interface MembersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) GLPGroup *group;

@end
