//
//  GLPAnimationHelper.m
//  Gleepost
//
//  Created by Silouanos on 06/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Super-class of animation helpers.

#import "GLPAnimationHelper.h"
#import "GLPiOSSupportHelper.h"
#import <POP/POP.h>

@implementation GLPAnimationHelper

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
 Abstract method.
 */
- (void)configureData
{
    
}

- (void)animateNevermindView:(UIView *)nevermindView withAppearance:(BOOL)show
{
    // 1. Pick a Kind Of Animation //  POPBasicAnimation  POPSpringAnimation POPDecayAnimation
    POPBasicAnimation *basicAnimation = [POPBasicAnimation animation];
    
    // 2. Decide weather you will animate a view property or layer property, Lets pick a View Property and pick kPOPViewFrame
    // View Properties - kPOPViewAlpha kPOPViewBackgroundColor kPOPViewBounds kPOPViewCenter kPOPViewFrame kPOPViewScaleXY kPOPViewSize
    // Layer Properties - kPOPLayerBackgroundColor kPOPLayerBounds kPOPLayerScaleXY kPOPLayerSize kPOPLayerOpacity kPOPLayerPosition kPOPLayerPositionX kPOPLayerPositionY kPOPLayerRotation kPOPLayerBackgroundColor
    
    // 3. Figure Out which of 3 ways to set toValue
    basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    basicAnimation.fromValue = (show) ? @(0.0) : @(1.0);
    basicAnimation.toValue = (show) ? @(1.0) : @(0.0);
    
    // 4. Create Name For Animation & Set Delegate
    basicAnimation.name=@"AnyAnimationNameYouWant";
    basicAnimation.delegate=self;
    
    // 5. Add animation to View or Layer, we picked View so self.tableView and not layer which would have been self.tableView.layer
    [nevermindView pop_addAnimation:basicAnimation forKey:@"WhatEverNameYouWant"];
}

#pragma mark - Helpers

- (CGFloat)getInitialElementsPosition
{
    return [GLPiOSSupportHelper screenHeight];
}

@end
