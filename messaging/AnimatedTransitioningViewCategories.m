//
//  AnimatedTransitioningViewCategories.m
//  Gleepost
//
//  Created by Silouanos on 22/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "AnimatedTransitioningViewCategories.h"
#import "GLPTimelineViewController.h"
#import "GLPCategoriesViewController.h"

@implementation AnimatedTransitioningViewCategories
//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    GLPCategoriesViewController *toVC = (GLPCategoriesViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    GLPTimelineViewController *fromVC = (GLPTimelineViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    toVC.view.alpha = 0.0;
    
    [inView addSubview:toVC.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //[toVC.view setFrame:CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    
    
    //UIViewAnimationOptionTransitionCrossDissolve
    //    toVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        toVC.view.alpha = 1.0;
        
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
    }];
    
    
    //    [UIView animateWithDuration:0.25f
    //                     animations:^{
    //
    //                         [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    //                     }
    //                     completion:^(BOOL finished) {
    //                         [transitionContext completeTransition:YES];
    //                     }];
}



@end
