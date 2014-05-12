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

@end

@implementation VideoProgressView

const float MAX_SECONDS = 12.0f;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self initialiseObjects];
    }
    
    return self;
}

-(void)initialiseObjects
{
    _currentProgress = 0.0f;
    [self setProgress:0.0f animated:NO];
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
    float progress = _currentProgress / MAX_SECONDS;
    
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

-(BOOL)doesCameraNeedsToEnd
{
    if(_currentProgress >= MAX_SECONDS)
    {
        return YES;
    }
    else
    {
        return NO;
    }
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
