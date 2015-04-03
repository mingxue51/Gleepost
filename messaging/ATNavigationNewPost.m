//
//  ATNavigationNewPost.m
//  Gleepost
//
//  Created by Silouanos on 04/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "ATNavigationNewPost.h"

@implementation ATNavigationNewPost


//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.0f;
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    
    UIViewController* toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];

//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        fromViewController.view.alpha = 0.0;
//    } completion:^(BOOL finished) {
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//    }];
    
    
//    UIView *inView = [transitionContext containerView];
//    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    
//
//    [transitionContext completeTransition:YES];
//
//    
//    
//    
//    if([self isPresenting])
//    {
//
//    }
//    else
//    {
//
//    }
    
}

@end
