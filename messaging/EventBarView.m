//
//  EventBarView.m
//  Gleepost
//
//  Created by Silouanos on 12/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
// TODO: Comments!

#import "EventBarView.h"
#import "AppearanceHelper.h"

@interface EventBarView ()

@property (weak, nonatomic) IBOutlet UIImageView *bar1;
@property (weak, nonatomic) IBOutlet UIImageView *bar2;
@property (weak, nonatomic) IBOutlet UIImageView *bar3;
@property (weak, nonatomic) IBOutlet UIImageView *bar4;

@property (strong, nonatomic) UIImageView *levelImageView;
@property (strong, nonatomic) UIImageView *levelImageShadowView;
@property (strong, nonatomic) UIImageView *circleThermometerImageView;
@property (assign, nonatomic) float height;
@property (assign, nonatomic) float currentHeight;
@property (assign, nonatomic) int popularity;

@property (weak, nonatomic) IBOutlet UIView *levelView;

@end

@implementation EventBarView


-(void)awakeFromNib
{
    [super awakeFromNib];
    
//    [self initialiseElements];
    
    [self configureViews];
}

-(void)initialiseElements
{
    _bar1.tag = 1;
    _bar2.tag = 2;
    _bar3.tag = 3;
    _bar4.tag = 4;
}

-(void)configureViews
{
    [self configureThermometer];
    
    [self configureThermometerShadow];
    
    [self configureThermometerCircleItem];
}

-(void)configureThermometerShadow
{
    _levelImageShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thermometer_shadow"]];
    _levelImageShadowView.center = _levelView.center;
    //    _levelImageView.contentMode = UIViewContentModeBottom;
    
    _levelImageShadowView.contentMode = UIViewContentModeScaleToFill;
    
//    _height = CGRectGetHeight(_levelImageShadowView.bounds);
    
    _height = 87.0f;

    
    DDLogDebug(@"HEIGHT: %f", _height);
    
    
    CGRect frame = _levelImageShadowView.frame;
    
//    frame.size.height = 0.00001;
    frame.size.height = 87.0;

    frame.origin.x = 3;
    frame.size.width = 10.0f;
    //    frame.origin.y += _height;
    
    _currentHeight = frame.origin.y = 0.0f;
    
    _levelImageShadowView.frame = frame;
    _levelImageShadowView.clipsToBounds = YES;
    
    _levelView.clipsToBounds = YES;
    

    
    [_levelView addSubview:_levelImageShadowView];
    
    [self bringSubviewToFront:_levelImageShadowView];

}

-(void)configureThermometer
{
    _levelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thermometer_color"]];

    _levelImageView.center = _levelView.center;

    
    _levelImageView.contentMode = UIViewContentModeScaleToFill;

    CGRect frame = _levelImageView.frame;

    frame.origin.x = 5;
    frame.size.width = 6.0f;
    
    [_levelImageView setFrame:frame];
    _levelImageView.clipsToBounds = YES;
    
    _levelView.clipsToBounds = YES;
    
    [_levelView addSubview:_levelImageView];
}



-(void)configureThermometerCircleItem
{
    _circleThermometerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thermometer_ball"]];
    //    _levelImageView.contentMode = UIViewContentModeBottom;
    _circleThermometerImageView.center = self.center;
    _circleThermometerImageView.contentMode = UIViewContentModeScaleToFill;
    
    
    CGRect frame = _circleThermometerImageView.frame;
    
    frame.origin.x = 4.0f;
    frame.size.width = 8.0f;
    frame.size.height = 0.00001f;
//    frame.origin.y = 87.0f;
    frame.origin.y = 95.0f;

    
    _circleThermometerImageView.frame = frame;
    _circleThermometerImageView.clipsToBounds = YES;
    
    self.clipsToBounds = YES;
    
    [self addSubview:_circleThermometerImageView];
    
    [self bringSubviewToFront:_circleThermometerImageView];

}

-(void)increaseLevelWithNumberOfAttendees:(NSInteger)number
{
    CGRect circleFrame = _circleThermometerImageView.frame;
    
    [self animateNumberOfAttendees:number];
    
    if(circleFrame.size.height == 0.00001f)
    {
        [self animateCircleWithHeight:8.0f andY:87.0f];
    }
    else
    {
        _currentHeight -= 1;
        
        [self animate];
    }
}

-(void)decreaseLevel
{
    CGRect circleFrame = _circleThermometerImageView.frame;

    if(circleFrame.size.height != 0.00001f && _currentHeight == 0)
    {
        [self animateCircleWithHeight:0.00001f andY:95.0f];
    }
    else
    {
        _currentHeight +=1;
        
        [self animate];
    }
}

/**
 Method used to initialise the thermometer level when new event fetch from the server.
 
 @param popularity of the event.
 
 */
-(void)setLevelWithPopularity:(int)popularity
{
    _popularity = popularity;
    
    if(popularity > 0)
    {
        [self animateCircleWithHeight:8.0f andY:87.0f];
    }
    
    _currentHeight -= popularity;
    
    [self animate];
}

#pragma mark - Animations

-(void)animateNumberOfAttendees:(NSInteger)number
{
    UILabel *lbl = [self createLabelAndAddItToCurrentViewWithText:[NSString stringWithFormat:@"%d",number]];
    
    [lbl setHidden:NO];

    
    [UIView animateWithDuration:0.7f delay:0.0f options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRectSetY(lbl, 90.0f);
        
    } completion:^(BOOL finished) {
        
        [lbl setHidden:YES];
        
        [lbl removeFromSuperview];
        
    }];

}

-(UILabel*)createLabelAndAddItToCurrentViewWithText:(NSString *)text
{
    UILabel *attendeesLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 160.0f, [self widthForText:text], 20.0f)];
    
    [attendeesLbl setText:text];
    
    [attendeesLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0]];
    
    [attendeesLbl setTextColor:[AppearanceHelper defaultGleepostColour]];
    
    [attendeesLbl setTextAlignment:NSTextAlignmentCenter];
    
    [attendeesLbl setHidden:YES];
    
    [[self superview] addSubview:attendeesLbl];
        
    return attendeesLbl;
}

-(float)widthForText:(NSString *)string
{
    if(string.length == 3)
    {
        return 35.0f;
    }
    else
    {
        return 25.0f;
    }
}

-(void)animateCircleWithHeight:(float)height andY:(float)y
{
    [UIView animateWithDuration:1.0f animations:^
     {
         
         CGRect frame = _circleThermometerImageView.frame;
         frame.size.height = height;
         frame.origin.y = y;
         
         _circleThermometerImageView.frame = frame;
         
     }];
}

-(void)animate
{
    [UIView animateWithDuration:1.0f animations:^
     {
         
         CGRect frame = _levelImageShadowView.frame;
         frame.size.height = _height;
         //         frame.origin.y -= _height;
         frame.origin.y = _currentHeight;
         
//         _levelImageView.frame = frame;
         _levelImageShadowView.frame = frame;

     }];
}

#pragma mark - Methods not used

-(void)increaseBarLevel:(int)level
{
    [self resetBars];

    
    if(level > 4 || level < 1)
    {
        return;
    }
    
    
    for(int i = 1; i<=level; ++i)
    {
        [self activateBarWithTag:i];
    }
    
}

-(void)decreaseBarLevel:(int)level
{
    for(int i = level; i>=1; --i)
    {
        [self deactivateBarWithTag:i];
    }
}

-(void)resetBars
{
    for(int i = 1; i<=4; ++i)
    {
        [self deactivateBarWithTag:i];
    }
}

-(void)deactivateBarWithTag:(int)tag
{
//    UIImageView *imgView = [self.subviews objectAtIndex:tag-1];
    
    UIImageView *imgView = [self subviewWithTag:tag];
    
    
//    [imgView setImage:[UIImage imageNamed:@"bar1"]];
    
    
    [imgView setHidden:YES];
}

-(void)activateBarWithTag:(int)tag
{
//    UIImageView *imgView = [self.subviews objectAtIndex:tag-1];
    
//    [imgView setImage:[UIImage imageNamed:@"bar1_selected"]];
    
    UIImageView *imgView = [self subviewWithTag:tag];
        
    [imgView setHidden:NO];
    
//    [imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",tag]]];

}

-(UIImageView *)subviewWithTag:(int)tag
{
    for(UIView *view in self.subviews)
    {
        if(view.tag == tag)
        {
            return (UIImageView *)view;
        }
    }
    
    return nil;
}

/**
 TODO: NOT USED.
 */

-(void)configureThermometerLevelItem
{
    _levelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thermometer_color"]];
    _levelImageView.center = _levelView.center;
    //    _levelImageView.contentMode = UIViewContentModeBottom;
    
    _levelImageView.contentMode = UIViewContentModeScaleToFill;
    
    _height = CGRectGetHeight(_levelImageView.bounds);
    
    DDLogDebug(@"HEIGHT: %f", _height);
    
    
    CGRect frame = _levelImageView.frame;
    
    frame.size.height = 0.00001;
    frame.origin.x = 3;
    frame.size.width = 10.0f;
    //    frame.origin.y += _height;
    
    _currentHeight = frame.origin.y = 87.0f;
    
    _levelImageView.frame = frame;
    _levelImageView.clipsToBounds = YES;
    
    _levelView.clipsToBounds = YES;
    
    [_levelView addSubview:_levelImageView];
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
