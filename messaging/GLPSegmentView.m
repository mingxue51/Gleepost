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
    [_leftBtn setTintColor:[AppearanceHelper defaultGleepostColour]];
}

- (void)leftButtonUnselected
{
    [_leftBtn setBackgroundColor:[UIColor colorWithR:229.0 withG:229.0 andB:229.0]];
    [_leftBtn setTintColor:[UIColor grayColor]];
}

- (void)rightButtonUnselected
{
    [_rightBtn setBackgroundColor:[UIColor colorWithR:229.0 withG:229.0 andB:229.0]];
    [_rightBtn setTintColor:[UIColor grayColor]];
}

- (void)rightButtonSelected
{
    [_rightBtn setBackgroundColor:[UIColor whiteColor]];
    [_rightBtn setTintColor:[AppearanceHelper defaultGleepostColour]];
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
