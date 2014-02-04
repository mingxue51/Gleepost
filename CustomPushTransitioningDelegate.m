//
//  CustomPushTransitioningDelegate.m
//  Gleepost
//
//  Created by Σιλουανός on 4/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CustomPushTransitioningDelegate.h"
#import "CustomPushTransitioning.h"

@interface CustomPushTransitioningDelegate ()

@property (strong, nonatomic) UIViewController *first;
@property (strong, nonatomic) UIViewController *destination;

@end

@implementation CustomPushTransitioningDelegate

-(id)initWithFirstController:(UIViewController*)first andDestinationController:(UIViewController*)destination
{
    self = [super init];
    
    if(self)
    {
        _first = first;
        _destination = destination;
    }
    
    return self;
}

#pragma mark - UIViewControllerTransitioning Delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    CustomPushTransitioning *controller = [[CustomPushTransitioning alloc]initWithFirstController:_first andDestinationController:_destination];
    controller.isPresenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    //TODO: FIX THAT, IMPORTANT.
    //I will fix it later.
    //    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc]init];
    //    controller.isPresenting = NO;
    //    return controller;
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

@end
