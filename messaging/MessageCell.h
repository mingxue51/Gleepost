//
//  MessageCell.h
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPMessage.h"

@interface MessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContentView;
@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *messageContentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;

@property (strong, nonatomic) NSString *cellIdentifier;
@property (assign, nonatomic) BOOL isLeft;

+ (CGFloat)getCellHeightWithMessage:(GLPMessage *)content first:(BOOL)isFirst;

- (void)updateWithMessage:(GLPMessage *)message first:(BOOL)isFirst;

@end
