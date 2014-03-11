//
//  GLPSearchUserCell.h
//  Gleepost
//
//  Created by Lukas on 3/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"

@protocol GLPSearchUserCellDelegate <NSObject>

- (void)checkButtonClickForUser:(GLPUser *)user;
- (void)overlayViewClickForUser:(GLPUser *)user;

@end

@interface GLPSearchUserCell : UITableViewCell

@property (weak, nonatomic) id<GLPSearchUserCellDelegate> delegate;

- (void)configureWithUser:(GLPUser *)user checked:(BOOL)checked;
-(void)configureWithUser:(GLPUser *)user;

@end
