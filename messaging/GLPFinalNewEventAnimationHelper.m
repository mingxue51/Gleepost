//
//  GLPFinalNewEventAnimationHelper.m
//  Gleepost
//
//  Created by Silouanos on 09/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPFinalNewEventAnimationHelper.h"
#import "GLPConstraintAnimationData.h"
#import "GLPiOSSupportHelper.h"
#import <POP/POP.h>

@implementation GLPFinalNewEventAnimationHelper

- (void)configureData
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kImageElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.15 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kVideoElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kLocationElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kTextElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kTitleElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kMainElement)];

    
    self.animationData = dictionary;
}

- (void)setInitialValueInConstraint:(NSLayoutConstraint *)constraint forView:(UIView *)view comingFromRight:(BOOL)fromRight
{
    [view layoutIfNeeded];
    CGFloat newValue = [GLPiOSSupportHelper screenWidth] + view.frame.size.width / 2;
    constraint.constant = (fromRight) ? -newValue : newValue;
}

- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)constraint withKindOfElement:(FinalNewPostViewElement)kindOfElement
{
    GLPConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfElement)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
        
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayoutConstraintConstant];
        basicAnimation.toValue = @(constraintAnimationData.finalValue);
        basicAnimation.springSpeed = constraintAnimationData.speed;
        basicAnimation.springBounciness = constraintAnimationData.bounce;
        
        basicAnimation.name=@"AnyAnimationNameYouWant";
        basicAnimation.delegate=self;
        
        [constraint pop_addAnimation:basicAnimation forKey:@"Appearing"];
    });
    
}
- (void)viewGoingBack:(BOOL)goingBack disappearingAnimationWithView:(UIView *)view andKindOfElement:(FinalNewPostViewElement)kindOfElement
{
    [view layoutIfNeeded];
    CGRect currentFrame = view.frame;
    
    GLPConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfElement)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
        
        NSValue *toValue = nil;
        NSString *animationName = nil;
        
        if(goingBack)
        {
            toValue = [NSValue valueWithCGRect:CGRectMake([GLPiOSSupportHelper screenWidth], currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height)];
            animationName = @"GoingBackDisappearing";
        }
        else
        {
            toValue = [NSValue valueWithCGRect:CGRectMake(-currentFrame.size.width, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height)];
            animationName = @"GoingForwardDisappearing";
        }
        
        basicAnimation.toValue = toValue;
        basicAnimation.springSpeed = constraintAnimationData.speed;
        basicAnimation.springBounciness = constraintAnimationData.bounce;
        
        basicAnimation.name = [NSString stringWithFormat:@"%@_%ld", animationName, (long)view.tag];
        basicAnimation.delegate=self;
        
        [view pop_addAnimation:basicAnimation forKey:@"Disappearing"];
    });
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    if([anim.name isEqualToString:@"GoingBackDisappearing_1"] && finished)
    {
        [(id<GLPFinalNewEventAnimationHelperDelegate>) self.delegate goingBackViewsDisappeared];
    }
}

@end
