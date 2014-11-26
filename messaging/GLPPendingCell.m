//
//  GLPPendingCell.m
//  Gleepost
//
//  Created by Silouanos on 25/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPendingCell.h"
#import "GLPPendingPostsManager.h"

@interface GLPPendingCell ()

@property (weak, nonatomic) IBOutlet UILabel *numberPendingPostsLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pendingPostsLabelWidth;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation GLPPendingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureCell];
    
    [self formatBackgroundImageView];
}

#pragma mark - Configuration

- (void)formatBackgroundImageView
{
}

- (void)configureCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Accessors

- (void)updateLabelWithNumberOfPendingPosts
{
    NSInteger numberOfPendingPosts = [[GLPPendingPostsManager sharedInstance] numberOfPendingPosts];
    
    [self.numberPendingPostsLabel setText:[@(numberOfPendingPosts) stringValue]];
}

+ (CGFloat)cellHeight
{
    return 50.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
