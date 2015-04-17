//
//  ATNavigationCategories.m
//  Gleepost
//
//  Created by Σιλουανός on 28/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ATFadeNavigation.h"
#import "NewPostViewController.h"
#import "GLPSelectCategoryViewController.h"


@implementation ATFadeNavigation

const float ANIMATION_TIME = 0.5;

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animationEnded:(BOOL) transitionCompleted
{

}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    GLPSelectCategoryViewController *toVC = (GLPSelectCategoryViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NewPostViewController *fromVC = (NewPostViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    
    [toVC.view setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0f]];
    
    if([self isPresenting])
    {
        CGRectSetX(toVC.view, 320.0f);
        
        [inView addSubview:toVC.view];
        
        
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            
            CGRectSetX(toVC.view, 0.0f);
            CGRectSetX(fromVC.view, -320.0f);
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];

        }];
    }
    else
    {
        CGRectSetX(toVC.view, -320.0f);
                
        [inView addSubview:toVC.view];
        
        
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            
            CGRectSetX(toVC.view, 0.0f);
            CGRectSetX(fromVC.view, 320.0f);
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            
        }];
    }

}

@end
