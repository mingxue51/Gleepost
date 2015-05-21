//
//  TransitionDelegateViewCategories.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "TransitionDelegateViewCategories.h"
#import "AnimatedTransitioningViewCategories.h"

@implementation TransitionDelegateViewCategories

//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioningViewCategories *controller = [[AnimatedTransitioningViewCategories alloc]init];
    controller.presenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    //I will fix it later.
    //    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc]init];
    //    controller.isPresenting = NO;
    //    return controller;
    
    
    //Here retrieve the very first view controller by just creating a new class to create the animation.
    
    AnimatedTransitioningViewCategories *controller = [[AnimatedTransitioningViewCategories alloc] init];
    controller.presenting = NO;
    
    return controller;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    NSLog(@"interactionControllerForDismissal");
    return nil;
}

@end
