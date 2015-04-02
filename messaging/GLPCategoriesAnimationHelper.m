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

@interface GLPCategoriesAnimationHelper ()

@property (assign, nonatomic) CGFloat allPostsViewY;
@property (assign, nonatomic) CGFloat firstRowY;
@property (assign, nonatomic) CGFloat secondRowY;
@property (assign, nonatomic) CGFloat thirdRowY;
@property (assign, nonatomic) CGFloat nevermindY;

@property (assign, nonatomic) CGFloat secondColumnDelay;

@end

@implementation GLPCategoriesAnimationHelper

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self intialisePositions];
        [self intialiseTiming];
    }
    return self;
}

- (void)intialisePositions
{
    self.allPostsViewY = 80.0f;
    self.firstRowY = 40.0f;
}

- (void)intialiseTiming
{
    self.secondColumnDelay = 0.2;
}

#pragma mark - Animations

- (void)animateAllPostsViewWithTopConstraint:(NSLayoutConstraint *)topConstraint
{
    // 1. Pick a Kind Of Animation //  POPBasicAnimation  POPSpringAnimation POPDecayAnimation
    POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
    
    // 2. Decide weather you will animate a view property or layer property, Lets pick a View Property and pick kPOPViewFrame
    // View Properties - kPOPViewAlpha kPOPViewBackgroundColor kPOPViewBounds kPOPViewCenter kPOPViewFrame kPOPViewScaleXY kPOPViewSize
    // Layer Properties - kPOPLayerBackgroundColor kPOPLayerBounds kPOPLayerScaleXY kPOPLayerSize kPOPLayerOpacity kPOPLayerPosition kPOPLayerPositionX kPOPLayerPositionY kPOPLayerRotation kPOPLayerBackgroundColor
    basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    
    // 3. Figure Out which of 3 ways to set toValue
    basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayoutConstraintConstant];
    basicAnimation.toValue = @(self.allPostsViewY);
    basicAnimation.springSpeed = 10.0f;
    basicAnimation.springBounciness = 10.0f;
    
    // 4. Create Name For Animation & Set Delegate
    basicAnimation.name=@"AnyAnimationNameYouWant";
    basicAnimation.delegate=self;
    
    // 5. Add animation to View or Layer, we picked View so self.tableView and not layer which would have been self.tableView.layer
    [topConstraint pop_addAnimation:basicAnimation forKey:@"WhatEverNameYouWant"];
}

- (void)animateFreeFoodViewWithTopConstraint:(NSLayoutConstraint *)topConstraint
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.secondColumnDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        // 1. Pick a Kind Of Animation //  POPBasicAnimation  POPSpringAnimation POPDecayAnimation
        POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
        
        // 3. Figure Out which of 3 ways to set toValue
        basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayoutConstraintConstant];
        basicAnimation.toValue = @(self.firstRowY);
        basicAnimation.springSpeed = 10.0f;
        basicAnimation.springBounciness = 4.0;
        
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
