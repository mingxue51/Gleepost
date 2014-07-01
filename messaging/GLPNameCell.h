//
//  GLPNameCell.h
//  Gleepost
//
//  Created by Σιλουανός on 1/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPUser;

@interface GLPNameCell : UITableViewCell

extern const float NAME_CELL_HEIGHT;


- (void)setUserData:(GLPUser *)user;

@end
