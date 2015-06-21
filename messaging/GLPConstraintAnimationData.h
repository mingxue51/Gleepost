//
//  GLPConstraintAnimationData.h
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPConstraintAnimationData : NSObject

- (instancetype)initWithFinalValue:(CGFloat)finalValue withDelay:(CGFloat)delay withBounceLevel:(CGFloat)bounce withSpeedLevel:(CGFloat)speed;

@property (assign, nonatomic) CGFloat finalValue;
@property (assign, nonatomic) CGFloat delay;
@property (assign, nonatomic) CGFloat bounce;
@property (assign, nonatomic) CGFloat speed;

@end
