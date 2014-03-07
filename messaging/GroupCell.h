//
//  GroupCell.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupDeletedDelegate.h"

@interface GroupCell : UITableViewCell <UIAlertViewDelegate>

-(void)setGroupData:(GLPGroup *)groupData;
-(void)setDelegate:(UIViewController <GroupDeletedDelegate> *)delegate;

@end
