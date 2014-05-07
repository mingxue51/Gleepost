//
//  LevelView.m
//  Gleepost
//
//  Created by Σιλουανός on 2/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class manages all the animations of the level view of the thermometer in CampusWallHeaderCell.

#import "LevelView.h"

@interface LevelView ()

@property (strong, nonatomic) UIImageView *levelImageView;
@property (strong, nonatomic) UIImageView *levelImageShadowView;
@property (assign, nonatomic) float height;
@property (assign, nonatomic) float currentHeight;

@end

@implementation LevelView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}

#pragma mark - Configuration

-(void)configureThermometerShadowWithSuperView:(EventBarView *)superView
{
    _levelImageShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thermometer_shadow"]];
    _levelImageShadowView.center = self.center;
    //    _levelImageView.contentMode = UIViewContentModeBottom;
    
    _levelImageShadowView.contentMode = UIViewContentModeScaleToFill;
    
    //    _height = CGRectGetHeight(_levelImageShadowView.bounds);
    
    _height = 87.0f;
//    [superView setFixedHeight:87.0f];
    
    CGRect frame = _levelImageShadowView.frame;
    
    //    frame.size.height = 0.00001;
    frame.size.height = 87.0;
    
    frame.origin.x = 3;
    frame.size.width = 10.0f;
    //    frame.origin.y += _height;
    
    _currentHeight = frame.origin.y = 0.0f;
//    [superView setCurrentHeight:0.0f];
    
    
    _levelImageShadowView.frame = frame;
    _levelImageShadowView.clipsToBounds = YES;
    
    self.clipsToBounds = YES;
    
    [self addSubview:_levelImageShadowView];
    
    [superView bringSubviewToFront:_levelImageShadowView];
}

-(void)configureThermometer
{
    _levelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thermometer_color"]];
    
    _levelImageView.center = self.center;
    
    
    _levelImageView.contentMode = UIViewContentModeScaleToFill;
    
    CGRect frame = _levelImageView.frame;
    
    frame.origin.x = 5;
    frame.size.width = 6.0f;
    
    [_levelImageView setFrame:frame];
    _levelImageView.clipsToBounds = YES;
    
    self.clipsToBounds = YES;
    
    [self addSubview:_levelImageView];
}

#pragma mark - Animations

-(void)animateLevelViewDown
{
    _currentHeight +=1;
    
    [self animate];
}

-(void)animateLevelViewUp
{
    _currentHeight -=1;
    
    [self animate];
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

-(void)animateLevelViewDownWithPopularity:(NSInteger)popularity
{
    DDLogDebug(@"Down height: %lf Popularity: %ld", _currentHeight, (long)popularity);
    
    _currentHeight =  _currentHeight + popularity;
    
    
    [self animateWithDelay:NO];
}

-(void)animateLevelViewUpWithPopularity:(NSInteger)popularity andDelay:(BOOL)delay
{
    _currentHeight -= (popularity - (-_currentHeight));
    
    
    [self animateWithDelay:delay];
}

-(void)animateWithDelay:(BOOL)delay
{
    [UIView animateWithDuration:1.0f delay:(delay) ? 0.7f : 0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = _levelImageShadowView.frame;
        frame.size.height = _height;
        //         frame.origin.y -= _height;
        frame.origin.y = _currentHeight;
        
        //         _levelImageView.frame = frame;
        _levelImageShadowView.frame = frame;
        
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)initialiseHeightWithPopularity:(NSInteger)popularity
{
    _currentHeight -= popularity;
    
    [self animate];
}

#pragma mark Accessors

-(BOOL)isCurrentHeightZero
{
    return (_currentHeight == 0);
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
