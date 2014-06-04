//
//  WTSecondScreenView.m
//  Gleepost
//
//  Created by Silouanos on 03/06/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "WTSecondScreenView.h"
#import "ShapeFormatterHelper.h"

@interface WTSecondScreenView ()

@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;


@end

@implementation WTSecondScreenView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self formatGetStartedButton];
    }
    return self;
}

- (void)formatGetStartedButton
{
    
    [ShapeFormatterHelper setBorderToView:_getStartedButton withColour:[UIColor whiteColor] andWidth:2.5f];
    
    [ShapeFormatterHelper setCornerRadiusWithView:_getStartedButton andValue:4];
    
}

- (IBAction)getStartedPushed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_DISMISS_WALKTHROUGH object:nil];
}


- (void)awakeFromNib
{
    [self formatGetStartedButton];
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
