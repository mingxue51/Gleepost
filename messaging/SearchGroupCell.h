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

extern const float SEARCH_GROUP_CELL_HEIGHT;

-(void)setGroupData:(GLPGroup *)groupData;
+ (float)getCellHeightWithGroup:(GLPGroup *)group;

@end
