//
//  TDNavigationCategories.m
//  Gleepost
//
//  Created by Σιλουανός on 28/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "TDNavigationCategories.h"
#import "ATNavigationCategories.h"

@implementation TDNavigationCategories

//===================================================================
// - UIViewControllerTransitioningDelegate
//===================================================================

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    ATNavigationCategories *controller = [[ATNavigationCategories alloc]init];
    controller.presenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    //I will fix it later.
    //    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc]init];
    //    controller.isPresenting = NO;
    //    return controller;
    
    
    NSLog(@"animationControllerForDismissedController");

    //Here retrieve the very first view controller by just creating a new class to create the animation.
    
    ATNavigationCategories *controller = [[ATNavigationCategories alloc]init];
    controller.presenting = NO;
    return controller;
    

}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    NSLog(@"interactionControllerForPresentation");
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    NSLog(@"interactionControllerForDismissal");
    return nil;
}
@end
