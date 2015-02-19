//
//  GLPMessageCell.h
//  Gleepost
//
//  Created by Lukas on 2/28/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPMessage.h"

@protocol GLPMessageCellDelegate <NSObject>

- (void)errorButtonClickForMessage:(GLPMessage *)message;
- (void)profileImageClickForMessage:(GLPMessage *)message;
- (void)readReceitClickForMessage:(GLPMessage *)message;
- (void)mainViewClickForMessage:(GLPMessage *)message;

@end


@interface GLPMessageCell : UITableViewCell

@property (weak, nonatomic) id<GLPMessageCellDelegate> delegate;

- (void)configureWithMessage:(GLPMessage *)message;
- (void)setViewMode:(BOOL)viewMode;
+ (CGFloat)viewHeightForMessage:(GLPMessage *)message;
+ (CGFloat)viewHeightForMessageInViewMode:(GLPMessage *)message;

@end
