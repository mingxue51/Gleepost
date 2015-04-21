//
//  GLPPollingOptionCell.m
//  Gleepost
//
//  Created by Silouanos on 20/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPPollingOptionCell.h"
#import "YLProgressBar.h"
#import "AppearanceHelper.h"

@interface GLPPollingOptionCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *separatorLineImageView;
@property (weak, nonatomic) IBOutlet YLProgressBar *progressBar;

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
- (void)setTitle:(NSString *)title withPercentage:(CGFloat)percentage withIndexRow:(NSInteger)indexRow enable:(BOOL)enable
{
    self.titleLabel.text = title;
    self.percentageLabel.text = [NSString stringWithFormat:@"%ld%@", (long)(percentage * 100), @"%"];
    self.progressBar.progress = percentage;
    [self enabledMode:enable];
    [self configureProgressBarWithIndexRow:indexRow];
}

- (void)enabledMode:(BOOL)enable
{
//    self.voteLevelProgressView.hidden = !enable;
    self.percentageLabel.hidden = !enable;
    self.progressBar.hidden = !enable;
    self.separatorLineImageView.hidden = enable;
}

- (void)configureProgressBarWithIndexRow:(NSInteger)indexRow
{
    self.progressBar.type = YLProgressBarTypeFlat;
    self.progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    self.progressBar.progressTintColors = @[[self colourWithIndexRow:indexRow]];
    self.progressBar.trackTintColor = [UIColor whiteColor];
    self.progressBar.hideStripes = YES;
    self.progressBar.stripesColor = [UIColor clearColor];
}

/**
 Returns a different colour depending on the table's view index row.
 
 @param indexRow table view's index row.
 
 @return the colour that we want to be applied on the progress view of the particular row.
 
 */
- (UIColor *)colourWithIndexRow:(NSInteger)indexRow
{
    switch (indexRow) {
        case 0:
            return [AppearanceHelper blueGleepostColour];
            break;
        
        case 1:
            return [AppearanceHelper greenGleepostColour];
            break;
         
        case 2:
            return [AppearanceHelper yellowGleepostColour];
            break;
            
        case 3:
            return [AppearanceHelper lightRedGleepostColour];
            break;

        default:
            return [AppearanceHelper grayGleepostColour];
            break;
    }
}

#pragma mark - Static

+ (CGFloat)height
{
    return 51.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
