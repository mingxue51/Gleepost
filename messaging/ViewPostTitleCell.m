//
//  ViewPostTitleCell.m
//  Gleepost
//
//  Created by Silouanos on 14/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "ViewPostTitleCell.h"

@interface ViewPostTitleCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ViewPostTitleCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
