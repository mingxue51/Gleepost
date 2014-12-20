//
//  GLPPendingCell.m
//  Gleepost
//
//  Created by Silouanos on 25/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPPendingCell.h"
#import "GLPPendingPostsManager.h"
#import "ShapeFormatterHelper.h"
#import "AppearanceHelper.h"

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
    [ShapeFormatterHelper setBorderToView:_backgroundImageView withColour:[AppearanceHelper borderGleepostColour] andWidth:1.5];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_backgroundImageView andValue:4];
}

- (void)configureCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureNumberLabelWidthWithText:(NSString *)text
{
    UIFont *font = [UIFont fontWithName:GLP_TITLE_FONT size:19.0];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    [self.pendingPostsLabelWidth setConstant:rect.size.width + 1.0];
}

#pragma mark - Accessors

- (void)updateLabelWithNumberOfPendingPosts
{
    NSInteger numberOfPendingPosts = [[GLPPendingPostsManager sharedInstance] numberOfPendingPosts];
    
    NSString *stringForLabel = [NSString stringWithFormat:@"(%@)", [@(numberOfPendingPosts) stringValue]];
    
    [self.numberPendingPostsLabel setText:stringForLabel];
    
    [self configureNumberLabelWidthWithText:stringForLabel];
}

+ (CGFloat)cellHeight
{
    return 40.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
