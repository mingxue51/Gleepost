//
//  DescriptionSegmentGroupCell.m
//  Gleepost
//
//  Created by Σιλουανός on 29/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "DescriptionSegmentGroupCell.h"
#import "GLPGroup.h"
#import "UILabel+Dimensions.h"
#import "ShapeFormatterHelper.h"

@interface DescriptionSegmentGroupCell ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;

@property (weak, nonatomic) IBOutlet GLPThreeSegmentView *segmentView;

@property (strong, nonatomic) UIFont *font;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeight;

@end

@implementation DescriptionSegmentGroupCell

const float GROUP_DESCR_VIEW_HEIGHT = 65;
const float DESCR_LBL_WIDTH = 290;

- (void)awakeFromNib
{
    // Initialization code
    
    [self configureFont];
    
    [self configureSegmentView];
}

- (void)setGroupData:(GLPGroup *)group
{
    [_descriptionLbl setText:group.groupDescription];
    
    [_labelHeight setConstant:[UILabel getContentLabelSizeForContent:group.groupDescription withFont:[UIFont fontWithName:GLP_HELV_NEUE_LIGHT size:15.0] andWidht:DESCR_LBL_WIDTH]];
    
//    [_descriptionLbl setHeightDependingOnText:group.groupDescription withFont:_font];
    
//    [ShapeFormatterHelper setBorderToView:_descriptionLbl withColour:[UIColor redColor] andWidth:1.0f];
    
}

#pragma mark - GLPSegmentViewDelegate

- (void)segmentSwitched:(ButtonType)conversationsType
{
    [_delegate segmentSwitchedWithButtonType:conversationsType];
}

#pragma mark - Configuration

- (void)configureSegmentView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GLPGroupSegmentView" owner:self options:nil];
    
    GLPThreeSegmentView *view = [array lastObject];
    view.tag = 100;
    [view setDelegate:self];
    [view setRightButtonTitle:@"Members" andLeftButtonTitle:@"Posts"];
    [view setSlideAnimationEnabled:NO];
    //    _segmentViewReference = view;
    
    [_segmentView addSubview:view];
}

- (void)configureFont
{
    _font = _descriptionLbl.font;
}

- (void)layoutSubviews
{
    //    [super layoutSubviews];
    
    
    //    [_segmentViewReference selectLeftButton];
    
    for(UIView *v in _segmentView.subviews)
    {
        if(v.tag == 100)
        {
            [(GLPThreeSegmentView *)v selectLeftButton];
        }
    }
    
}

#pragma mark - Static

+ (float)getCellHeightWithGroup:(GLPGroup *)group
{
    float lblHeight = [UILabel getContentLabelSizeForContent:group.groupDescription withFont:[UIFont fontWithName:GLP_HELV_NEUE_LIGHT size:15.0] andWidht:DESCR_LBL_WIDTH];
    
    
    return lblHeight + GROUP_DESCR_VIEW_HEIGHT;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
