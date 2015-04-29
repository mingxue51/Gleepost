//
//  GLPFNBPageController.m
//  Gleepost
//
//  Created by Silouanos on 08/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Class that controls the 4 or 2 dots on the FakeNavigationBarNewPostView.

#import "GLPFNBPageController.h"
#import "ShapeFormatterHelper.h"
#import "UIColor+GLPAdditions.h"
#import "AppearanceHelper.h"

@interface GLPFNBPageController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *dots;

@end

@implementation GLPFNBPageController


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self formatElements];
}

#pragma mark - Configuration

- (void)formatElements
{
    for(UIImageView *dot in self.dots)
    {
        [ShapeFormatterHelper setRoundedView:dot toDiameter:dot.frame.size.height];
    }
}

#pragma mark - UI changes

- (void)selectDotWithNumber:(NSInteger)number
{
    [self makeAllDotsUnselected];
    [self makeSelectedDotWithNumber:number];
}

- (void)makeAllDotsUnselected
{
    for(UIImageView *dot in self.dots)
    {
        [dot setBackgroundColor:[UIColor colorWithR:230.0 withG:230.0 andB:230.0]];
    }
}

- (void)makeSelectedDotWithNumber:(NSInteger)number
{
    for(UIImageView *dot in self.dots)
    {
        if(number == dot.tag)
        {
            [dot setBackgroundColor:[AppearanceHelper blueGleepostColour]];
        }
    }
}

#pragma mark - Operations

/**
 Removes the 2 dots in the edges and acts as having 2 dots.
 @param shortMode if YES should turn to 2 dots otherwise should be regular.
 */
- (void)setShortModeAndMakeSecondDotSelected
{
    for(UIImageView *dot in self.dots)
    {
        if(dot.tag == 1 || dot.tag == 4)
        {
            dot.hidden = YES;
        }
    }
    
    [self selectDotWithNumber:3];
}

- (void)setThreeDotsMode
{
    for(UIImageView *dot in self.dots)
    {
        if(dot.tag == 4)
        {
            dot.hidden = YES;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
