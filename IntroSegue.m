//
//  IntroSegue.m
//  Gleepost
//
//  Created by Σιλουανός on 16/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "IntroSegue.h"

@implementation IntroSegue

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL];

    [destinationViewController.view addSubview:sourceViewController.view];

    
    
    [UIView animateWithDuration:0.5f animations:^{
       
       CGRectSetY(sourceViewController.view, 1000.0);

        
    } completion:^(BOOL finished) {

        
    }];
    
}

@end
