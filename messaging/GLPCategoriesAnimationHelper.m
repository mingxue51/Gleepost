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

@end

@implementation GLPCategoriesAnimationHelper

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self intialisePositions];
    }
    return self;
}

- (void)intialisePositions
{
    self.allPostsViewY = 80.0f;
}

#pragma mark - Animations

- (void)animateAllPostsViewWithTopConstraint:(NSLayoutConstraint *)topConstrain
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
    [topConstrain pop_addAnimation:basicAnimation forKey:@"WhatEverNameYouWant"];
}

- (CGFloat)getInitialElementsPosition
{
    return [GLPiOSSupportHelper screenHeight] + 100.0f;
}

@end
