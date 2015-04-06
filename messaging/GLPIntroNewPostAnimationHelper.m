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
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalY:105.0 withDelay:0.25 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kGeneralElement)];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalY:105.0 withDelay:0.25 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kAnnouncementElement)];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalY:50.0 withDelay:0.0 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kPencilElement)];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalY:110.0 withDelay:0.0 withBounceLevel:4.0 withSpeedLevel:12.0] forKey:@(kTitleElement)];
    
    self.animationData = dictionary.mutableCopy;
}

- (void)viewDidLoadAnimationWithConstraint:(NSLayoutConstraint *)layoutConstraint andKindOfElement:(IntroNewPostViewElement)kindOfElement
{
    GLPConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfElement)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
        
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayoutConstraintConstant];
        basicAnimation.toValue = @(constraintAnimationData.finalY);
        basicAnimation.springSpeed = constraintAnimationData.speed;
        basicAnimation.springBounciness = constraintAnimationData.bounce;
        
        basicAnimation.name=@"AnyAnimationNameYouWant";
        basicAnimation.delegate=self;
        
        [layoutConstraint pop_addAnimation:basicAnimation forKey:@"Appearing"];
    });
}

- (void)viewDisappearingAnimationWithView:(UIView *)view andKindOfElement:(IntroNewPostViewElement)kindOfElement
{
    [view layoutIfNeeded];
    
    CGRect currentFrame = view.frame;
    
    GLPConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfElement)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        POPBasicAnimation *basicAnimation = [POPBasicAnimation animation];
        
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
        basicAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(-currentFrame.origin.x - currentFrame.size.width, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height)];
        
        basicAnimation.name=[NSString stringWithFormat:@"%ld", (long)view.tag];;
        basicAnimation.delegate=self;
        
        [view pop_addAnimation:basicAnimation forKey:@"Disappearing"];
    });
}

- (void)firstViewAnimationsWithView:(UIView *)view
{
    CGRect currentFrame = view.frame;

    // 1. Pick a Kind Of Animation //  POPBasicAnimation  POPSpringAnimation POPDecayAnimation
    POPBasicAnimation *basicAnimation = [POPBasicAnimation animation];
    
    // 2. Decide weather you will animate a view property or layer property, Lets pick a View Property and pick kPOPViewFrame
    // View Properties - kPOPViewAlpha kPOPViewBackgroundColor kPOPViewBounds kPOPViewCenter kPOPViewFrame kPOPViewScaleXY kPOPViewSize
    // Layer Properties - kPOPLayerBackgroundColor kPOPLayerBounds kPOPLayerScaleXY kPOPLayerSize kPOPLayerOpacity kPOPLayerPosition kPOPLayerPositionX kPOPLayerPositionY kPOPLayerRotation kPOPLayerBackgroundColor
    
    // 3. Figure Out which of 3 ways to set toValue
    basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    basicAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(currentFrame.origin.x, -currentFrame.size.height - 50, currentFrame.size.width, currentFrame.size.height)];
    
    //    basicAnimation.springSpeed = 1;
    //    basicAnimation.springBounciness = 0;
    // 4. Create Name For Animation & Set Delegate
    basicAnimation.name=[NSString stringWithFormat:@"%ld", (long)view.tag];
    basicAnimation.delegate=self;
    
    // 5. Add animation to View or Layer, we picked View so self.tableView and not layer which would have been self.tableView.layer
    [view pop_addAnimation:basicAnimation forKey:@"WhatEverNameYouWant"];
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    NSInteger viewTag = [anim.name integerValue];

    //Tag = 99 is the Nevermind button.
    
    if(viewTag == 99 && finished)
    {
        [self.delegate viewsDisappeared];
    }
}

#pragma mark - Helpers

- (CGFloat)getInitialElementsPosition
{
    return [GLPiOSSupportHelper screenHeight];
}

@end
