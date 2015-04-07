//
//  GLPEventNewPostAnimationHelper.m
//  Gleepost
//
//  Created by Silouanos on 07/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPEventNewPostAnimationHelper.h"
#import "GLPConstraintAnimationData.h"
#import <POP/POP.h>
#import "GLPiOSSupportHelper.h"

@implementation GLPEventNewPostAnimationHelper

#pragma mark - Configuration

- (void)configureData
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:100.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kPartiesElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.15 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kFreeFoodElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:100.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kSportsElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kSpeakersElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.25 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kMusicElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:-100.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kTheaterElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:-100.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kOtherElement)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.0 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kCalendarElement)];

    self.animationData = dictionary;
}

/**
 Sets the X value for a view in order to know the final value of the view.
 @param view the animatable view.
 */
- (void)setXValueForView:(UIView *)view withKindOfElement:(EventNewPostViewElement)kindOfElement
{
    [view layoutIfNeeded];
    GLPConstraintAnimationData *animationData = [self.animationData objectForKey:@(kindOfElement)];
    animationData.finalValue = view.frame.origin.x;
}

- (void)setInitialValueInConstraint:(NSLayoutConstraint *)constraint forView:(UIView *)view
{
    [view layoutIfNeeded];
    constraint.constant = -[GLPiOSSupportHelper screenWidth] - view.frame.size.width / 2;
}

- (void)renewDelay:(CGFloat)delay withKindOfElement:(EventNewPostViewElement)kindOfElement
{
    GLPConstraintAnimationData *animationData = [self.animationData objectForKey:@(kindOfElement)];
    animationData.delay = delay;
}

#pragma mark - Animations

- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)constraint withKindOfElement:(EventNewPostViewElement)kindOfElement
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


- (void)viewGoingBackDisappearingAnimationWithView:(UIView *)view andKindOfElement:(EventNewPostViewElement)kindOfElement
{
    [view layoutIfNeeded];
    CGRect currentFrame = view.frame;
    
    GLPConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfElement)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
        
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
        basicAnimation.toValue = [NSValue valueWithCGRect:CGRectMake([GLPiOSSupportHelper screenWidth], currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height)];
        basicAnimation.springSpeed = constraintAnimationData.speed;
        basicAnimation.springBounciness = constraintAnimationData.bounce;
        
        basicAnimation.name = [NSString stringWithFormat:@"GoingBackDisappearing_%ld", (long)view.tag];
        basicAnimation.delegate=self;
        
        [view pop_addAnimation:basicAnimation forKey:@"Disappearing"];
    });
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    if([anim.name isEqualToString:@"GoingBackDisappearing_1"] && finished)
    {
        [(id<GLPEventNewPostAnimationHelperDelegate>) self.delegate goingBackViewsDisappeared];
    }
}

@end
