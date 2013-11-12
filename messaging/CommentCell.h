//
//  CommentCell.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPComment.h"
#import "ViewPostViewController.h"

@interface CommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postDateLabel;
@property (strong, nonatomic) UIView *socialPanelView;
@property (strong, nonatomic) UIButton *likeButtonButton;
@property (readwrite, assign) float height;
@property (weak, nonatomic) ViewPostViewController *delegate;

+ (CGFloat)getCellHeightWithContent:(NSString *)content image:(BOOL)isImage;
-(void)setCellHeight:(NSString*)content;
-(void)setComment:(GLPComment*)comment;
@end
