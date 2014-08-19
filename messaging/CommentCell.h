//
//  CommentCell.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPComment.h"
#import "GLPImageView.h"
#import "GLPLabel.h"

typedef NS_ENUM(NSUInteger, CommentCellType) {
    kTopCommentCell,
    kMiddleCommentCell,
    kBottomCommentCell,
    kTopBottomCommentCell
};

@interface CommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet GLPImageView *userImageView;
@property (strong, nonatomic) IBOutlet GLPLabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postDateLabel;
//@property (strong, nonatomic) UIView *socialPanelView;
//@property (strong, nonatomic) UIButton *likeButtonButton;
@property (weak, nonatomic) UIViewController<GLPImageViewDelegate, GLPLabelDelegate> *delegate;

+ (CGFloat)getCellHeightWithContent:(NSString *)content image:(BOOL)isImage;
-(void)setCellHeight:(NSString*)content;
-(void)setComment:(GLPComment*)comment withIndex:(NSInteger)index andNumberOfComments:(NSInteger)commentsNumber;

@end
