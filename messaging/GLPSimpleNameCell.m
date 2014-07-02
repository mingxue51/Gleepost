//
//  GLPNameCell.m
//  Gleepost
//
//  Created by Σιλουανός on 1/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSimpleNameCell.h"

@interface GLPSimpleNameCell ()


@end

@implementation GLPSimpleNameCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

#pragma mark - Modifiers

- (void)setUserData:(GLPUser *)user
{
    [super setUserData:user];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
