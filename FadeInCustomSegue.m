//
//  FadeInCustomSegue.m
//  Gleepost
//
//  Created by Σιλουανός on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "FadeInCustomSegue.h"

@implementation FadeInCustomSegue

- (void) perform
{
    
//    [UIView transitionWithView:[(UIViewController *)self.sourceViewController view] duration:0.2
//                       options:UIViewAnimationOptionTransitionFlipFromLeft
//                    animations:^{
//                        [(UIViewController *)self.sourceViewController pushViewController: (UIViewController *)self.destinationViewController animated:NO];
//                    }
//                    completion:NULL];
    
    

//    CATransition *transition = [CATransition animation];
//    transition.duration = 1;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionFade;
//    transition.delegate = self.sourceViewController;
//    [[(UIViewController *)self.sourceViewController view].layer addAnimation:transition forKey:nil];
//    [(UIViewController *)self.sourceViewController view].hidden = YES;
//    [(UIViewController *)self.destinationViewController view].hidden = NO;
  
    
//    CATransition* transition = [CATransition animation];
//    
//    transition.duration = 1.0;
//    transition.type = kCATransitionFade;
//    
//    [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
//    [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];
    
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    // Add the destination view as a subview, temporarily
    [sourceViewController.view addSubview:destinationViewController.view];
    
    // Transformation start scale
    destinationViewController.view.transform = CGAffineTransformMakeScale(0.05, 0.05);
    
    // Store original centre point of the destination view
    CGPoint originalCenter = destinationViewController.view.center;
    // Set center to start point of the button
    destinationViewController.view.center = self.originatingPoint;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Grow!
                         destinationViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         destinationViewController.view.center = originalCenter;
                     }
                     completion:^(BOOL finished){
                         [destinationViewController.view removeFromSuperview]; // remove from temp super view
                         [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL]; // present VC
                     }];
   
}

@end
