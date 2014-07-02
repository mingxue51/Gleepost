//
//  GLPNameCell.h
//  Gleepost
//
//  Created by Σιλουανός on 2/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  Super class of the following classes:
//  GLPCheckNameCell, GLPSimpleNameCell.
//

#import <UIKit/UIKit.h>

@class GLPUser;

@interface GLPNameCell : UITableViewCell

extern const float NAME_CELL_HEIGHT;

- (void)setUserData:(GLPUser *)user;
- (GLPUser *)user;

@end
