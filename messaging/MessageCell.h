//
//  MessageCell.h
//  Gleepost
//
//  Created by Lukas on 10/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContentView;
@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *messageContentImageView;

@property (strong, nonatomic) NSString *cellIdentifier;

+ (CGFloat)getCellHeightWithContent:(NSString *)content first:(BOOL)isFirst;

- (void)updateWithMessage:(Message *)message first:(BOOL)isFirst;

@end
