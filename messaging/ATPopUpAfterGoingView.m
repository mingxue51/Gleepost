//
//  ATPopUpAfterGoingView.m
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ATPopUpAfterGoingView.h"
#import "ViewPostViewController.h"
#import "GLPPopUpDialogViewController.h"

@implementation ATPopUpAfterGoingView

const float ANIMATION_TIME_POP_UP = 0.2;

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    DDLogDebug(@"Animation ended.");
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    
    GLPPopUpDialogViewController *toVC = (GLPPopUpDialogViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
//    ViewPostViewController *fromVC = (ViewPostViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if([self isPresenting])
    {
        [toVC.view setAlpha:0.0];
        [inView addSubview:toVC.view];
        
        
        [UIView animateWithDuration:ANIMATION_TIME_POP_UP animations:^{
            
            [toVC.view setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            
        }];
    }
    else
    {
        [UIView animateWithDuration:ANIMATION_TIME_POP_UP animations:^{
            
            [inView setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            
        }];
    }
    
}

@end
