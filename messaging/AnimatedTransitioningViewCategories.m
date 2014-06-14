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

const float ANIMATION_TIME_2 = 0.5;

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    

    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //[toVC.view setFrame:CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    
    
    //UIViewAnimationOptionTransitionCrossDissolve
    //    toVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    
    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    
    
    DDLogDebug(@"To view: %@, from view: %@", toVC.class, fromVC.class);
    
    if([self isPresenting])
    {
        toVC.view.alpha = 0.0;
        
        [inView addSubview:toVC.view];
        
        
        NSString *keyPath = @"position.y";
        id finalValue = [NSNumber numberWithFloat:300];
        
        SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
        bounceAnimation.fromValue = [NSNumber numberWithFloat:toVC.view.center.x];
        toVC.view.alpha = 1.0;
        bounceAnimation.toValue = finalValue;
        bounceAnimation.duration = 0.5f;
        bounceAnimation.numberOfBounces = 4;
        bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
        bounceAnimation.shouldOvershoot = YES;
        
        [toVC.view.layer addAnimation:bounceAnimation forKey:@"someKey"];
        
        [toVC.view.layer setValue:finalValue forKeyPath:keyPath];
        
        [transitionContext completeTransition:YES];
    }
    else
    {
        DDLogDebug(@"Animation completed.");
        
//        [inView addSubview:fromVC.view];
        [transitionContext completeTransition:YES];

        
//        [UIView animateWithDuration:2.0f animations:^{
//        
//            inView.alpha = 0.0;
//
//        } completion:^(BOOL finished) {
//
//            
//            
//        }];
        
        
        
        
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
