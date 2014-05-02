//
//  ThermometerCircleView.m
//  Gleepost
//
//  Created by Σιλουανός on 2/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ThermometerCircleView.h"

@implementation ThermometerCircleView

-(id)initWithSuperView:(EventBarView *)superView
{
    self = [super init];
    
    if(self)
    {
        //Initialise the image.
        [self initialiseImage];
        [self initialisePositionWithSuperView:superView];
    }
    
    return self;
}

#pragma mark - Configuration

-(void)initialiseImage
{
    [self setImage:[UIImage imageNamed:@"thermometer_ball"]];
}

-(void)initialisePositionWithSuperView:(EventBarView *)superView
{
    self.center = superView.center;
    self.contentMode = UIViewContentModeScaleToFill;
    
    
    CGRect frame = self.frame;
    
    frame.origin.x = 4.0f;
    frame.size.width = 8.0f;
    frame.size.height = 0.00001f;
    //    frame.origin.y = 87.0f;
    frame.origin.y = 95.0f;
    
    
    self.frame = frame;
    self.clipsToBounds = YES;
    
    superView.clipsToBounds = YES;
    
    [superView addSubview:self];
    
    [superView bringSubviewToFront:self];
}

#pragma mark - Animations

-(void)animateCircleWithHeight:(float)height andY:(float)y
{
    [UIView animateWithDuration:1.0f animations:^
     {
         
         CGRect frame = self.frame;
         frame.size.height = height;
         frame.origin.y = y;
         
         self.frame = frame;
         
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
