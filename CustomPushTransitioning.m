//
//  CustomPushTransitioning.m
//  Gleepost
//
//  Created by Σιλουανός on 4/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CustomPushTransitioning.h"

@interface CustomPushTransitioning ()

@property (strong, nonatomic) UIViewController *first;
@property (strong, nonatomic) UIViewController *destination;

@end

@implementation CustomPushTransitioning 

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

#pragma mark - UIViewControllerAnimatedTransitioning delegate

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 2.0f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
//    NewPostViewController *toVC = (NewPostViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    TimelineViewController *fromVC = (TimelineViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    
    [inView addSubview:_destination.view];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [_destination.view setFrame:CGRectMake(screenRect.size.width, 0, _first.view.frame.size.width, _first.view.frame.size.height)];
    
    [UIView animateWithDuration:2.0f animations:^{
                         
        [_destination.view setFrame:CGRectMake(0, 0, _first.view.frame.size.width, _first.view.frame.size.height)];
    }
    completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
    }];
}





@end
