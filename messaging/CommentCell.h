//
//  CommentCell.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentCell : UITableViewCell

@property (strong, nonatomic) UITextView *contentTextView;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *postDateLabel;
@property (strong, nonatomic) UIView *socialPanelView;
@property (strong, nonatomic) UIButton *likeButtonButton;
@property (readwrite, assign) float height;

-(void) createElements;


@end
