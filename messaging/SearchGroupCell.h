//
//  GroupCell.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPGroup.h"


@interface SearchGroupCell : UITableViewCell

- (void)setGroupData:(GLPGroup *)groupData;
- (UIImage *)groupImage;
+ (float)getCellHeightWithGroup:(GLPGroup *)group;

@end
