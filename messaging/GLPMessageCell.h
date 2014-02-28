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

@end


@interface GLPMessageCell : UITableViewCell

@property (weak, nonatomic) id<GLPMessageCellDelegate> delegate;

- (void)configureWithMessage:(GLPMessage *)message;
+ (CGFloat)viewHeightForMessage:(GLPMessage *)message;

@end
