//
//  GLPSegmentView.m
//  Gleepost
//
//  Created by Σιλουανός on 19/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPSegmentView.h"
#import "AppearanceHelper.h"
#import "UIColor+GLPAdditions.h"
#import "ShapeFormatterHelper.h"

@interface GLPSegmentView ()

@property (weak, nonatomic) IBOutlet UIButton *leftBtn;

@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (weak, nonatomic) IBOutlet UIImageView *slideImageView;

@property (assign, nonatomic) CGPoint slideImageViewPosition;

@property (assign, nonatomic) ButtonType conversationType;

@end


@implementation GLPSegmentView

const float ANIMATION_DURATION = 0.3;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
//        [self configuration];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configuration];
    [self formatElements];
}

- (void)configuration
{
    _conversationType = kButtonLeft;
    
    [self reloadButtonsFormat];
}

- (void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:self andValue:4];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_slideImageView andValue:4];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_rightBtn andValue:4];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_leftBtn andValue:4];
}

#pragma mark - Modifiers

/**
 If this method is not called then the titles of the buttons will be the default ones. (Private - Group)
 */
- (void)setRightButtonTitle:(NSString *)rightTitle andLeftButtonTitle:(NSString *)leftTitle
{
    [_rightBtn setTitle:rightTitle forState:UIControlStateNormal];
    
    [_leftBtn setTitle:leftTitle forState:UIControlStateNormal];
}

- (void)selectRightButton
{
    _conversationType = kButtonRight;
    [self reloadButtonsFormat];
}

- (void)selectLeftButton
{
    _conversationType = kButtonLeft;
    [self reloadButtonsFormat];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //Make sure that the slider is on the right side.
    
    [self refreshSlider];
    
    
}

#pragma mark - Actions

- (IBAction)leftBtnPressed:(id)sender
{
    _conversationType = kButtonLeft;
    [self reloadButtonsFormat];
}

- (IBAction)rightBtnPressed:(id)sender
{
    _conversationType = kButtonRight;
    [self reloadButtonsFormat];

}

#pragma mark - Format buttons

- (void)refreshSlider
{
    [_slideImageView setHidden:YES];
    
    if(_conversationType == kButtonLeft)
    {
        CGRectSetX(_slideImageView, _leftBtn.frame.origin.x);
    }
    else
    {
        CGRectSetX(_slideImageView, _rightBtn.frame.origin.x);
    }
    
    [_slideImageView setHidden:NO];
    
}

- (void)reloadButtonsFormat
{
    if(_conversationType == kButtonLeft)
    {
        [self leftButtonSelected];
    }
    else
    {
        [self rightButtonSelected];
    }
}

- (void)leftButtonSelected
{
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
        CGRectSetX(_slideImageView, _leftBtn.frame.origin.x);
        
    } completion:^(BOOL finished) {
        
        [_delegate segmentSwitched:_conversationType];

        [_leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[AppearanceHelper colourForUnselectedSegment] forState:UIControlStateNormal];
        
    }];
}

- (void)rightButtonSelected
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
        CGRectSetX(_slideImageView, _rightBtn.frame.origin.x);
        
        
    } completion:^(BOOL finished) {
        
        [_delegate segmentSwitched:_conversationType];

        [_rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[AppearanceHelper colourForUnselectedSegment] forState:UIControlStateNormal];
    }];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
