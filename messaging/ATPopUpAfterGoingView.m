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
#import "UIColor+GLPAdditions.h"

@implementation ATPopUpAfterGoingView

const float ANIMATION_TIME_POP_UP = 0.1;

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
    
    [toVC.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75]];
    
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if([self isPresenting])
    {
        [toVC.view setAlpha:1.0];
        [inView addSubview:toVC.view];
        [transitionContext completeTransition:YES];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
            
            [fromVC.view setAlpha:0.0];
        
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
        
        }];
    }
}

@end
