//
//  GLPIntroNewPostAnimationHelper.m
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPIntroNewPostAnimationHelper.h"
#import <POP/POP.h>
#import "GLPConstraintAnimationData.h"
#import "GLPiOSSupportHelper.h"

@implementation GLPIntroNewPostAnimationHelper


- (void)configureData
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:105.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kGeneralElement)];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:105.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kAnnouncementElement)];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:105.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kEventElement)];

    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:105.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kQuestionElement)];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue: ([GLPiOSSupportHelper useShortConstrains]) ? 10.0 : 50.0 withDelay:0.15 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kPencilElement)];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:([GLPiOSSupportHelper useShortConstrains]) ? 50.0 : 110.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kTitleElement)];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:0.0 withDelay:0.0 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kNevermindElement)];
    
    self.animationData = dictionary.mutableCopy;
}

#pragma mark - Positioning

//- (void)setPositionsOnElementsAfterGoingForwardWithConstraint:(NSLayoutConstraint *)constraint andView:(UIView *)view
//{
//    [view layoutIfNeeded];
//    
//}

- (void)renewFinalValueWithConstraint:(NSLayoutConstraint *)constraint forKindOfElement:(IntroNewPostViewElement)kindOfElement
{
    GLPConstraintAnimationData *animationData = [self.animationData objectForKey:@(kindOfElement)];
    animationData.finalValue = constraint.constant;
}

- (void)renewDelay:(CGFloat)delay withKindOfElement:(IntroNewPostViewElement)kindOfElement
{
    GLPConstraintAnimationData *animationData = [self.animationData objectForKey:@(kindOfElement)];
    animationData.delay = delay;
}

- (void)setPositionToView:(UIView *)view afterForwardingWithConstraint:(NSLayoutConstraint *)constraint withMinusSign:(BOOL)minusSign
{
    [view layoutIfNeeded];
    
    CGFloat newConstant = [GLPiOSSupportHelper screenWidth] + view.frame.size.width;
    constraint.constant = (minusSign) ? -newConstant : newConstant;
}

#pragma mark - Animations

- (void)viewDidAppearAnimationWithConstraint:(NSLayoutConstraint *)layoutConstraint andKindOfElement:(IntroNewPostViewElement)kindOfElement
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
        
        [layoutConstraint pop_addAnimation:basicAnimation forKey:@"Appearing"];
    });
}

- (void)viewDisappearingAnimationWithView:(UIView *)view withKindOfElement:(IntroNewPostViewElement)kindOfElement andViewDismiss:(BOOL)dismissedView
{
    [view layoutIfNeeded];
    
    CGRect currentFrame = view.frame;
    
    GLPConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfElement)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
        
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
        
        NSValue *toValue = nil;
        NSString *animationName = nil;
        if(dismissedView)
        {
            toValue = [NSValue valueWithCGRect:CGRectMake(currentFrame.origin.x, [GLPiOSSupportHelper screenHeight] + currentFrame.size.height, currentFrame.size.width, currentFrame.size.height)];
            animationName = @"Dismiss";
        }
        else
        {
            toValue = [NSValue valueWithCGRect:CGRectMake(-currentFrame.origin.x - currentFrame.size.width, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height)];
            animationName = @"GoForward";
        }
        
        basicAnimation.toValue = toValue;
        basicAnimation.springSpeed = 10.0;
//        basicAnimation.springBounciness = 0.0;
        
        basicAnimation.name=[NSString stringWithFormat:@"%@_%ld", animationName, (long)view.tag];
        basicAnimation.delegate=self;
        
        [view pop_addAnimation:basicAnimation forKey:@"Disappearing"];
    });
}

- (void)animateElementAfterComingBackWithConstraint:(NSLayoutConstraint *)layoutConstraint andKindOfElement:(IntroNewPostViewElement)kindOfElement
{
    
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    NSString *animationNameTag = anim.name;

    //Tag = 99 is the Nevermind button.
    
    if([animationNameTag isEqualToString:@"GoForward_99"] && finished)
    {
        [self.delegate viewsDisappeared];
    }
    else if([animationNameTag isEqualToString:@"Dismiss_99"] && finished)
    {
        [(id<GLPIntroNewPostAnimationHelperDelegate>) self.delegate viewReadyToBeDismissed];
    }
}

#pragma mark - Helpers

- (CGFloat)getInitialElementsPosition
{
    return [GLPiOSSupportHelper screenHeight];
}

@end
