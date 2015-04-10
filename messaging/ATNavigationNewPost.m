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
    
    UIView *inView = [transitionContext containerView];
    UIViewController* toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if(!self.isPresenting)
    {
        CGRectSetX(toViewController.view, 320.0f);
        
        [inView addSubview:toViewController.view];
        
        [UIView animateWithDuration:0.1 animations:^{
            
            CGRectSetX(toViewController.view, 0.0f);
            CGRectSetX(fromViewController.view, -320.0f);
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            
        }];
        
//        [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    }
    
    
//    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];

    //[transitionContext completeTransition:YES];

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
