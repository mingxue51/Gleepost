//
//  GLPFinalNewEventAnimationHelper.m
//  Gleepost
//
//  Created by Silouanos on 09/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPFinalNewEventAnimationHelper.h"
#import "GLPConstraintAnimationData.h"

@implementation GLPFinalNewEventAnimationHelper

- (void)configureData
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kImageElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.15 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kVideoElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kLocationElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kTextElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kTitleElement)];


    
    self.animationData = dictionary;
}

- (void)setInitialValueInConstraint:(NSLayoutConstraint *)constraint forView:(UIView *)view comingFromRight:(BOOL)minusSign;
{
    
}

- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)constraint withKindOfElement:(FinalNewPostViewElement)kindOfElement
{
    
}
- (void)viewGoingBack:(BOOL)goingBack disappearingAnimationWithView:(UIView *)view andKindOfElement:(FinalNewPostViewElement)kindOfElement
{
    
}

@end
