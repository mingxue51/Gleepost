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
#import "SKBounceAnimation.h"

@implementation AnimatedTransitioningViewCategories

const float CATEGORIES_ANIMATION_TIME = 0.15;

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    return CATEGORIES_ANIMATION_TIME;
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //[toVC.view setFrame:CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    
    
    //UIViewAnimationOptionTransitionCrossDissolve
    //    toVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    
    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];


    
    if([self isPresenting])
    {
        toVC.view.alpha = 0.0;
        
        [inView addSubview:toVC.view];
        
        
        [UIView animateWithDuration:CATEGORIES_ANIMATION_TIME animations:^{
           
            toVC.view.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];

        }];
        
        
//        NSString *keyPath = @"position.y";
////        id finalValue = [NSNumber numberWithFloat:350];
//        id finalValue = [NSNumber numberWithFloat:toVC.view.center.y];
//        
//        
//        SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
//        bounceAnimation.fromValue = [NSNumber numberWithFloat:toVC.view.center.x];
//        toVC.view.alpha = 1.0;
//        bounceAnimation.toValue = finalValue;
//        bounceAnimation.duration = CATEGORIES_ANIMATION_TIME;
//        bounceAnimation.numberOfBounces = 4;
//        bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
//        bounceAnimation.shouldOvershoot = YES;
//        
//        [toVC.view.layer addAnimation:bounceAnimation forKey:@"someKey"];
//        
//        [toVC.view.layer setValue:finalValue forKeyPath:keyPath];
        
    }
    else
    {
        //The transition is done in the view controller.

        [UIView animateWithDuration:CATEGORIES_ANIMATION_TIME animations:^{
        
            fromVC.view.alpha = 0.0;

        } completion:^(BOOL finished) {

            [transitionContext completeTransition:YES];
            
        }];
        
        
        
        
//        NSString *keyPath = @"position.y";
//        id finalValue = [NSNumber numberWithFloat:0];
//        
//        SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
//        bounceAnimation.fromValue = [NSNumber numberWithFloat:fromVC.view.center.x];
//        fromVC.view.alpha = 1.0;
//        bounceAnimation.toValue = finalValue;
//        bounceAnimation.duration = 0.5f;
//        bounceAnimation.numberOfBounces = 4;
//        bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
//        bounceAnimation.shouldOvershoot = YES;
//        
//        [fromVC.view.layer addAnimation:bounceAnimation forKey:@"someKey"];
//        
//        [fromVC.view.layer setValue:finalValue forKeyPath:keyPath];
        
    }
    

}



@end
