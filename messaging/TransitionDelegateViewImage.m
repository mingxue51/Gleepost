//
//  TransitionDelegate.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "TransitionDelegateViewImage.h"
#import "AnimatedTransitioningViewImage.h"
#import "ATNavigationCategories.h"

@implementation TransitionDelegateViewImage

//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioningViewImage *controller = [[AnimatedTransitioningViewImage alloc]init];
    controller.isPresenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//I will fix it later.
//    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc]init];
//    controller.isPresenting = NO;
//    return controller;
    
    NSLog(@"animationControllerForDismissedController");

    ATNavigationCategories *controller = [[ATNavigationCategories alloc]init];
    controller.isPresenting = YES;
    return controller;
    
    
//    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    NSLog(@"interactionControllerForPresentation");

    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    NSLog(@"interactionControllerForDismissal");
    return nil;
}

@end
