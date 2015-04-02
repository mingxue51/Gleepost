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

@interface ConstraintAnimationData : NSObject

@property (assign, nonatomic) CGFloat finalY;
@property (assign, nonatomic) CGFloat delay;
@property (assign, nonatomic) CGFloat bounce;
@property (assign, nonatomic) CGFloat speed;

@end

@implementation ConstraintAnimationData

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

@interface GLPCategoriesAnimationHelper ()

/** This data structure has a key, value: <KindOfElement enum, ConstraintAnimationData>. */
@property (strong, nonatomic) NSDictionary *animationData;

@end

@implementation GLPCategoriesAnimationHelper

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self configureData];
    }
    return self;
}

/**
 Here we are configuring the NSDictionary that contains all the animation data of the elements.
 */
- (void)configureData
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:80.0 withDelay:0.0 withBounceLevel:10.0 withSpeedLevel:10.0] forKey:@(kAllOrder)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:20.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kPartiesOrder)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:20.0 withDelay:0.3 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kFreeFood)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:20.0 withDelay:0.2 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kSportsOrder)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:20.0 withDelay:0.4 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kSpeakersOrder)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:20.0 withDelay:0.5 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kMusicOrder)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:20.0 withDelay:0.4 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kTheaterOrder)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:60.0 withDelay:0.6 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kAnnouncementsOrder)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:60.0 withDelay:0.5 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kGeneralOrder)];
    [dictionary setObject:[[ConstraintAnimationData alloc] initWithFinalY:60.0 withDelay:0.6 withBounceLevel:4.0 withSpeedLevel:10.0] forKey:@(kQuestionsOrder)];
    
    self.animationData = dictionary;
}

#pragma mark - Animations

- (void)animateElementWithTopConstraint:(NSLayoutConstraint *)topConstraint withKindOfView:(CategoryOrder)kindOfView
{
    ConstraintAnimationData *constraintAnimationData = [self.animationData objectForKey:@(kindOfView)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, constraintAnimationData.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        // 1. Pick a Kind Of Animation //  POPBasicAnimation  POPSpringAnimation POPDecayAnimation
        POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
        
        // 2. Decide weather you will animate a view property or layer property, Lets pick a View Property and pick kPOPViewFrame
        // View Properties - kPOPViewAlpha kPOPViewBackgroundColor kPOPViewBounds kPOPViewCenter kPOPViewFrame kPOPViewScaleXY kPOPViewSize
        // Layer Properties - kPOPLayerBackgroundColor kPOPLayerBounds kPOPLayerScaleXY kPOPLayerSize kPOPLayerOpacity kPOPLayerPosition kPOPLayerPositionX kPOPLayerPositionY kPOPLayerRotation kPOPLayerBackgroundColor
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
        
        // 3. Figure Out which of 3 ways to set toValue
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayoutConstraintConstant];
        basicAnimation.toValue = @(constraintAnimationData.finalY);
        basicAnimation.springSpeed = constraintAnimationData.speed;
        basicAnimation.springBounciness = constraintAnimationData.bounce;
        
        // 4. Create Name For Animation & Set Delegate
        basicAnimation.name=@"AnyAnimationNameYouWant";
        basicAnimation.delegate=self;
        
        // 5. Add animation to View or Layer, we picked View so self.tableView and not layer which would have been self.tableView.layer
        [topConstraint pop_addAnimation:basicAnimation forKey:@"WhatEverNameYouWant"];
        
    });
}

#pragma mark - Helpers

- (CGFloat)getInitialElementsPosition
{
    return [GLPiOSSupportHelper screenHeight] + 100.0f;
}

@end
