//
//  GLPCheckNameCell.h
//  Gleepost
//
//  Created by Σιλουανός on 2/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPNameCell.h"

@protocol GLPCheckNameCellDelegate <NSObject>

@required
- (void)userCheckedWithUser:(GLPUser *)user;
- (void)userUncheckedWithUser:(GLPUser *)user;

@end

@interface GLPCheckNameCell : GLPNameCell

@property (weak, nonatomic) UIViewController <GLPCheckNameCellDelegate> *delegate;

- (void)setUserData:(GLPUser *)user withCheckedStatus:(BOOL)checked;

@end
