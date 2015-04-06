//
//  GLPConstraintAnimationData.m
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Class to help us to store animation data for each animatable element.
//  (Used in Animation Helper classes).

#import "GLPConstraintAnimationData.h"

@implementation GLPConstraintAnimationData

- (instancetype)initWithFinalY:(CGFloat)finalY withDelay:(CGFloat)delay withBounceLevel:(CGFloat)bounce withSpeedLevel:(CGFloat)speed
{
    self = [super init];
    
    if (self)
    {
        self.finalY = finalY;
        self.delay = delay;
        self.bounce = bounce;
        self.speed = speed;
    }
    
    return self;
}

@end
