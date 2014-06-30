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

//@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
//
//@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (weak, nonatomic) IBOutlet UILabel *leftLbl;

@property (weak, nonatomic) IBOutlet UILabel *rightLbl;

@property (weak, nonatomic) IBOutlet UIImageView *slideImageView;

@property (assign, nonatomic) CGPoint slideImageViewPosition;

@property (assign, nonatomic) ButtonType conversationType;

@end


@implementation GLPSegmentView

const float ANIMATION_DURATION = 0.1;

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
    [self configureGesturesToLabels];
}

- (void)configuration
{
    _conversationType = kButtonLeft;
    
    [self reloadButtonsFormat];
}

- (void)configureGesturesToLabels
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftBtnPressed:)];
    [tap setNumberOfTapsRequired:1];
    [_leftLbl addGestureRecognizer:tap];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightBtnPressed:)];
    [tap setNumberOfTapsRequired:1];
    [_rightLbl addGestureRecognizer:tap];
}

- (void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:self andValue:4];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_slideImageView andValue:4];
}

#pragma mark - Modifiers

/**
 If this method is not called then the titles of the buttons will be the default ones. (Private - Group)
 */
- (void)setRightButtonTitle:(NSString *)rightTitle andLeftButtonTitle:(NSString *)leftTitle
{
    [_rightLbl setText:rightTitle];
    
    [_leftLbl setText:leftTitle];
}

- (void)selectRightButton
{
    _conversationType = kButtonRight;
    [self refreshSlider];
}

- (void)selectLeftButton
{
    _conversationType = kButtonLeft;
    [self refreshSlider];
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
    if(_conversationType == kButtonLeft)
    {
        CGRectSetX(_slideImageView, _leftLbl.frame.origin.x);
        
        [_leftLbl setTextColor:[UIColor blackColor]];
        [_leftLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0]];
        
        [_rightLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0]];
        [_rightLbl setTextColor:[AppearanceHelper colourForUnselectedSegment]];
    }
    else
    {
        CGRectSetX(_slideImageView, _rightLbl.frame.origin.x);
        
        [_rightLbl setTextColor:[UIColor blackColor]];
        [_rightLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0]];
        
        [_leftLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0]];
        [_leftLbl setTextColor:[AppearanceHelper colourForUnselectedSegment]];
    }
}

- (void)reloadButtonsFormat
{
    
    if(_conversationType == kButtonLeft)
    {
        DDLogDebug(@"reloadButtonsFormat kButtonLeft");

        [self leftButtonSelected];
    }
    else
    {
        DDLogDebug(@"reloadButtonsFormat kButtonRight");

        [self rightButtonSelected];
    }
}

- (void)leftButtonSelected
{
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
        CGRectSetX(_slideImageView, _leftLbl.frame.origin.x);
        
    } completion:^(BOOL finished) {
        
        [_delegate segmentSwitched:_conversationType];
        
        [_leftLbl setTextColor:[UIColor blackColor]];
        [_leftLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0]];
        
        [_rightLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0]];
        [_rightLbl setTextColor:[AppearanceHelper colourForUnselectedSegment]];
        
    }];
}

- (void)rightButtonSelected
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
        CGRectSetX(_slideImageView, _rightLbl.frame.origin.x);
        
        
    } completion:^(BOOL finished) {
        
        [_delegate segmentSwitched:_conversationType];
        
        
        [_rightLbl setTextColor:[UIColor blackColor]];
        [_rightLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0]];
        
        [_leftLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0]];
        [_leftLbl setTextColor:[AppearanceHelper colourForUnselectedSegment]];
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
