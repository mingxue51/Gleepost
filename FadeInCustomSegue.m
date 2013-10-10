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
    
//    [UIView transitionWithView:src.navigationController.view duration:0.2
//                       options:UIViewAnimationOptionTransitionFlipFromLeft
//                    animations:^{
//                        [src.navigationController pushViewController:dst animated:NO];
//                    }
//                    completion:NULL];
    
    

//    CATransition *transition = [CATransition animation];
//    transition.duration = 1;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionFade;
//    transition.delegate = src;
//    [src.view.layer addAnimation:transition forKey:nil];
//    src.view.hidden = YES;
//    dst.view.hidden = NO;
  
    
    CATransition* transition = [CATransition animation];
    
    transition.duration = 1.0;
    transition.type = kCATransitionFade;
    
    [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
    [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];
   
}

@end
