//
//  GLPCategoriesAnimationHelper.m
//  Gleepost
//
//  Created by Silouanos on 02/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  In this class there are all the animations for each individual kind of element in the Categories Filtering view.

#import "GLPCategoriesAnimationHelper.h"
#import <POP/POP.h>
#import "GLPiOSSupportHelper.h"
#import "GLPConstraintAnimationData.h"

@implementation GLPCategoriesAnimationHelper

/**
 Here we are configuring the NSDictionary that contains all the animation data of the elements.
 */
- (void)configureData
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:80.0 withDelay:0.0 withBounceLevel:10.0 withSpeedLevel:20.0] forKey:@(kAllOrder)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:55.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kPartiesOrder)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:55.0 withDelay:0.15 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kFreeFood)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:55.0 withDelay:0.1 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kSportsOrder)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:10.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kSpeakersOrder)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:10.0 withDelay:0.25 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kMusicOrder)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:10.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kTheaterOrder)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:70.0 withDelay:0.3 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kAnnouncementsOrder)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:70.0 withDelay:0.25 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kGeneralOrder)];
    [dictionary setObject:[[GLPConstraintAnimationData alloc] initWithFinalValue:70.0 withDelay:0.3 withBounceLevel:4.0 withSpeedLevel:20.0] forKey:@(kQuestionsOrder)];
    
    self.animationData = dictionary;
}

#pragma mark - Animations

- (void)animateElementWithTopConstraint:(NSLayoutConstraint *)topConstraint withKindOfView:(CategoryOrder)kindOfView
{
    GLPConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfView)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        // 1. Pick a Kind Of Animation //  POPBasicAnimation  POPSpringAnimation POPDecayAnimation
        POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
        
        // 2. Decide weather you will animate a view property or layer property, Lets pick a View Property and pick kPOPViewFrame
        // View Properties - kPOPViewAlpha kPOPViewBackgroundColor kPOPViewBounds kPOPViewCenter kPOPViewFrame kPOPViewScaleXY kPOPViewSize
        // Layer Properties - kPOPLayerBackgroundColor kPOPLayerBounds kPOPLayerScaleXY kPOPLayerSize kPOPLayerOpacity kPOPLayerPosition kPOPLayerPositionX kPOPLayerPositionY kPOPLayerRotation kPOPLayerBackgroundColor
        
        // 3. Figure Out which of 3 ways to set toValue
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayoutConstraintConstant];
        basicAnimation.toValue = @(constraintAnimationData.finalValue);
        basicAnimation.springSpeed = constraintAnimationData.speed;
        basicAnimation.springBounciness = constraintAnimationData.bounce;
        
        // 4. Create Name For Animation & Set Delegate
        basicAnimation.name=@"AnyAnimationNameYouWant";
        basicAnimation.delegate=self;
        
        // 5. Add animation to View or Layer, we picked View so self.tableView and not layer which would have been self.tableView.layer
        [topConstraint pop_addAnimation:basicAnimation forKey:@"WhatEverNameYouWant"];
    });
}

- (void)dismissElementWithView:(UIView *)view withKindOfView:(CategoryOrder)kindOfView
{
    [view layoutIfNeeded];
    
    CGRect currentFrame = view.frame;
    
    GLPConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfView)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
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
        
    });

}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    NSInteger viewTag = [anim.name integerValue];
    
    if(viewTag == 10 && finished)
    {
        [self.delegate viewsDisappeared];
    }
}

@end
