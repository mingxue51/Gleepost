//
//  GroupCell.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupDeletedDelegate.h"

@interface GroupCell : UITableViewCell

-(void)setName:(NSString *)name withImageUrl:(NSString *)imageUrl andRemoteKey:(int)groupRemoteKey;
-(void)setDelegate:(UIViewController <GroupDeletedDelegate> *)delegate;

@end
