//
//  AnimatedTransitioning.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "AnimatedTransitioningViewImage.h"
#import "GLPTimelineViewController.h"
//#import "ViewPostImageViewController.h"
#import "GLPViewImageViewController.h"

@implementation AnimatedTransitioningViewImage

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    DDLogDebug(@"transitionCompleted");
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
//    ViewPostImageViewController *toVC = (ViewPostImageViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    
//    GLPViewImageViewController *toVC = (GLPViewImageViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    
    //    GLPTimelineViewController *fromVC = (GLPTimelineViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if(_isPresenting)
    {
        toVC.view.alpha = 0.0;
        
        [inView addSubview:toVC.view];
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
            toVC.view.alpha = 1.0;
            
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
            
        }];
    }
    else
    {
        //The transition is done in the view controller.
        
            [transitionContext completeTransition:YES];
    }
}



@end
