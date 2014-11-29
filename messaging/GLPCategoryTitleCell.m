//
//  GLPCategoryTitleCell.m
//  Gleepost
//
//  Created by Silouanos on 26/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCategoryTitleCell.h"

@interface GLPCategoryTitleCell ()

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation GLPCategoryTitleCell

const CGFloat CATEGORY_TITLE_HEIGHT = 30.0;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addObservers];
}

- (void)dealloc
{
    [self removeObservers];
}

#pragma mark - Notifications

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCategoryLabel:) name:GLPNOTIFICATION_UPDATE_CATEGORY_LABEL object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_UPDATE_CATEGORY_LABEL object:nil];
    
}

- (void)updateCategoryLabel:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *category = [dict objectForKey:@"Category"];
    
    [_categoryLabel setText:[NSString stringWithFormat:@"%@ posts", category]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
