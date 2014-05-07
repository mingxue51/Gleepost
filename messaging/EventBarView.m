//
//  EventBarView.m
//  Gleepost
//
//  Created by Silouanos on 12/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
// The current class manage all animations of the thermometer bar in CampusWallHeaderCell.


#import "EventBarView.h"
#import "AppearanceHelper.h"
#import "LevelView.h"
#import "ThermometerCircleView.h"

@interface EventBarView ()

@property (weak, nonatomic) IBOutlet UIImageView *bar1;
@property (weak, nonatomic) IBOutlet UIImageView *bar2;
@property (weak, nonatomic) IBOutlet UIImageView *bar3;
@property (weak, nonatomic) IBOutlet UIImageView *bar4;

@property (strong, nonatomic) ThermometerCircleView *circleThermometerImageView;

@property (weak, nonatomic) IBOutlet LevelView *levelView;

@end

@implementation EventBarView


-(void)awakeFromNib
{
    [super awakeFromNib];
    
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
    [_levelView configureThermometerShadowWithSuperView:self];
}

-(void)configureThermometer
{
    [_levelView configureThermometer];
}


-(void)configureThermometerCircleItem
{
    _circleThermometerImageView = [[ThermometerCircleView alloc] initWithSuperView:self];
}

-(void)increaseLevelWithNumberOfAttendees:(NSInteger)number andPopularity:(NSInteger)popularity
{
    CGRect circleFrame = _circleThermometerImageView.frame;
    
    [self animateNumberOfAttendees:number];
    
    
    
    if(circleFrame.size.height == 0.00001f)
    {
        [_circleThermometerImageView animateCircleWithHeight:8.0f andY:87.0f];

        
        if(popularity > 1)
        {
            [_levelView animateLevelViewUpWithPopularity:popularity andDelay:YES];
        }
        
    }
    else
    {
//        [_levelView animateLevelViewUp];
        
        [_levelView animateLevelViewUpWithPopularity:popularity andDelay:NO];
        
    }
}


-(void)animateAllTogetherWithPopularity:(NSInteger)popularity
{
//    [UIView animateWithDuration:1.0f animations:^{
//        
//        CGRect frame = self.frame;
//        frame.size.height = 8.0f;
//        frame.origin.y = 87.0f;
//        
//        self.frame = frame;
//        
//    } completion:^(BOOL finished) {
//        
//        if(popularity > 1)
//        {
//        }
//        
//    }];
    
    if(popularity > 1)
    {
        [_levelView animateLevelViewUp];
    }
}

-(void)decreaseLevelWithPopularity:(NSInteger)popularity
{
    CGRect circleFrame = _circleThermometerImageView.frame;

    if(circleFrame.size.height != 0.00001f && [_levelView isCurrentHeightZero])
    {
        [_circleThermometerImageView animateCircleWithHeight:0.00001f andY:95.0f];
    }
    else
    {
     
        if(popularity == 0)
        {
            [_circleThermometerImageView animateCircleWithHeight:0.00001f andY:95.0f];
        }
        
        [_levelView animateLevelViewDownWithPopularity:popularity];
//        [_levelView animateLevelViewDown];
    }
}

/**
 Method used to initialise the thermometer level when new event fetch from the server.
 
 @param popularity of the event.
 
 */
-(void)setLevelWithPopularity:(int)popularity
{
    if(popularity > 0)
    {
        [_circleThermometerImageView animateCircleWithHeight:8.0f andY:87.0f];
    }
    
    [_levelView initialiseHeightWithPopularity:popularity];

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

//-(void)configureThermometerLevelItem
//{
//    _levelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thermometer_color"]];
//    _levelImageView.center = _levelView.center;
//    //    _levelImageView.contentMode = UIViewContentModeBottom;
//    
//    _levelImageView.contentMode = UIViewContentModeScaleToFill;
//    
//    _height = CGRectGetHeight(_levelImageView.bounds);
//    
//    DDLogDebug(@"HEIGHT: %f", _height);
//    
//    
//    CGRect frame = _levelImageView.frame;
//    
//    frame.size.height = 0.00001;
//    frame.origin.x = 3;
//    frame.size.width = 10.0f;
//    //    frame.origin.y += _height;
//    
//    _currentHeight = frame.origin.y = 87.0f;
//    
//    _levelImageView.frame = frame;
//    _levelImageView.clipsToBounds = YES;
//    
//    _levelView.clipsToBounds = YES;
//    
//    [_levelView addSubview:_levelImageView];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
