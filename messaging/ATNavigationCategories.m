//
//  ATNavigationCategories.m
//  Gleepost
//
//  Created by Σιλουανός on 28/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "ATNavigationCategories.h"
#import "NewPostViewController.h"
#import "GLPSelectCategoryViewController.h"


@implementation ATNavigationCategories

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    DDLogDebug(@"animationEnded");
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    GLPSelectCategoryViewController *toVC = (GLPSelectCategoryViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NewPostViewController *fromVC = (NewPostViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
//    toVC.view.alpha = 0.0;
    CGRectSetX(toVC.view, 320.0f);
    
    [inView addSubview:toVC.view];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        CGRectSetX(toVC.view, 0.0f);
        CGRectSetX(fromVC.view, -320.0f);
        
    } completion:^(BOOL finished) {
    
    }];
    
    
    //    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
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
