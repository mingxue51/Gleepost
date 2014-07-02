//
//  GLPNameCell.h
//  Gleepost
//
//  Created by Σιλουανός on 1/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPNameCell.h"

@class GLPUser;

@interface GLPSimpleNameCell : GLPNameCell

- (void)setUserData:(GLPUser *)user;

@end
