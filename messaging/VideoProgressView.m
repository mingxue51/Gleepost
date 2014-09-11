//
//  VideoProgressView.m
//  Gleepost
//
//  Created by Silouanos on 12/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "VideoProgressView.h"

@interface VideoProgressView ()

@property (assign, nonatomic) float currentProgress;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) float currentCountDownProgress;
@end

@implementation VideoProgressView

const float MAX_SECONDS = 12.0f;
const float MIN_SECONDS = 5.0f;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self initialiseObjects];
        [self formatProgressView];
    }
    
    return self;
}

-(void)initialiseObjects
{
    _currentProgress = 0.0f;
    _currentCountDownProgress = MAX_SECONDS;
    [self setProgress:0.0f animated:NO];
}

-(void)formatProgressView
{
    [self setTransform:CGAffineTransformMakeScale(1.0, 7.0)];
}

/**
 Starts the automatic progress of the bar.
 */
-(void)startProgress
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
}


/**
 Pause the automatic progress.
 */
-(void)pauseProgress
{
    [_timer invalidate];
}

-(void)stopProgress
{
    [self pauseProgress];
    
    [self initialiseObjects];
}

-(void)updateProgressBar:(id)sender
{
    _currentProgress += 0.01f;
    _currentCountDownProgress -= 0.01f;
    float progress = _currentProgress / MAX_SECONDS;
    
    [self informMainViewSeconds:(NSInteger)_currentCountDownProgress];
    
    if([self doesReachedThreshold])
    {
        [self informMainViewToShowProcessButton];
    }
    
    if([self doesCameraNeedsToEnd])
    {
        [self informCameraToStop];
    }
    else
    {
        [self setProgress:progress animated:YES];
    }
}

-(void)informCameraToStop
{
    //Post notification to GLPVideoViewController.
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CAMERA_LIMIT_REACHED object:nil];
}

/**
 This method is called when the recording duration is more that 5 seconds.
 This method informs the main view to enable the continue button.
 */
-(void)informMainViewToShowProcessButton
{
    //Post notification to GLPVideoViewController.
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CAMERA_THRESHOLD_REACHED object:nil];
}

-(void)informMainViewSeconds:(NSInteger)seconds
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_SECONDS_TEXT_TITLE object:nil userInfo:@{@"seconds":[NSNumber numberWithInteger:seconds]}];
}

-(BOOL)doesCameraNeedsToEnd
{
    return (_currentProgress >= MAX_SECONDS) ? YES : NO;
}

-(BOOL)doesReachedThreshold
{
    return (_currentProgress >= MIN_SECONDS) ? YES : NO;
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
