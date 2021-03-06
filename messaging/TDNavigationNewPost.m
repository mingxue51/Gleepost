//
//  TDNavigationNewPost.m
//  Gleepost
//
//  Created by Silouanos on 04/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "TDNavigationNewPost.h"
#import "ATNavigationNewPost.h"

@implementation TDNavigationNewPost

//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    ATNavigationNewPost *controller = [[ATNavigationNewPost alloc]init];
    controller.presenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    //Here retrieve the very first view controller by just creating a new class to create the animation.
    
    DDLogDebug(@"Finished new post animation");
    
    ATNavigationNewPost *controller = [[ATNavigationNewPost alloc]init];
    controller.presenting = NO;
    return controller;
    
    
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    return nil;
}

@end
