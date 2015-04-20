//
//  GLPPollingOptionCell.m
//  Gleepost
//
//  Created by Silouanos on 20/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPPollingOptionCell.h"

@interface GLPPollingOptionCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
//@property (weak, nonatomic) IBOutlet UIProgressView *voteLevelProgressView;

@end

@implementation GLPPollingOptionCell

- (void)awakeFromNib {
    // Initialization code
}

/**
 Sets the title and the percentage to the cell.
 Percentage and progress bar is visible only when the enable is YES.
 
 @param title the title of the option.
 @param percentage the percentage of the vote.
 @param enable if YES then show all the data (percentage and bar).
 */
- (void)setTitle:(NSString *)title withPercentage:(CGFloat)percentage enable:(BOOL)enable
{
    self.titleLabel.text = title;
    self.percentageLabel.text = [NSString stringWithFormat:@"%f%@", percentage * 100, @"%"];
}

+ (CGFloat)height
{
    return 51.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
