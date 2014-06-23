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

@property (assign, nonatomic) ConversationType conversationType;

@end


@implementation GLPSegmentView

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
    [self configuration];
    [self formatElements];
}

- (void)configuration
{
    _conversationType = kPrivate;
    
    [self reloadButtonsFormat];
}

- (void)formatElements
{
    [ShapeFormatterHelper setCornerRadiusWithView:self andValue:4];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_rightBtn andValue:4];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_leftBtn andValue:4];
}

#pragma mark - Actions

- (IBAction)leftBtnPressed:(id)sender
{
    _conversationType = kPrivate;
    [self reloadButtonsFormat];
}

- (IBAction)rightBtnPressed:(id)sender
{
    _conversationType = kGroup;
    [self reloadButtonsFormat];

}

#pragma mark - Format buttons

- (void)reloadButtonsFormat
{
    [_delegate segmentSwitched:_conversationType];
    
    if(_conversationType == kPrivate)
    {
        [self leftButtonSelected];
        [self rightButtonUnselected];
    }
    else
    {
        [self rightButtonSelected];
        [self leftButtonUnselected];
    }
}

- (void)leftButtonSelected
{
    [_leftBtn setBackgroundColor:[UIColor whiteColor]];
    [_leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)leftButtonUnselected
{
    [_leftBtn setBackgroundColor:[AppearanceHelper colourForTableViewSeparatorLines]];
    [_leftBtn setTitleColor:[AppearanceHelper colourForUnselectedSegment] forState:UIControlStateNormal];
}

- (void)rightButtonUnselected
{
    [_rightBtn setBackgroundColor:[AppearanceHelper colourForTableViewSeparatorLines]];
    [_rightBtn setTitleColor:[AppearanceHelper colourForUnselectedSegment] forState:UIControlStateNormal];
}

- (void)rightButtonSelected
{
    [_rightBtn setBackgroundColor:[UIColor whiteColor]];
    [_rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
