//
//  IntroSegue.m
//  Gleepost
//
//  Created by Σιλουανός on 16/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "IntroSegue.h"
#import "GLPiOSSupportHelper.h"
#import "GLPSingInViewController.h"
#import "GLPTabBarController.h"

@implementation IntroSegue

- (void)perform
{
    
//    if([GLPiOSSupportHelper isIOS7])
//    {
//        UIViewController *sourceViewController = self.sourceViewController;
//        UIViewController *destinationViewController = self.destinationViewController;
//        
//        
//        DDLogDebug(@"Source VC: %@, Destination VC: %@", [sourceViewController class], [destinationViewController class]);
//        
//        
//        [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL];
//        
//        [destinationViewController.view addSubview:sourceViewController.view];
//        
//        
//        
//        [UIView animateWithDuration:0.5f animations:^{
//            
//            CGRectSetY(sourceViewController.view, 1000.0);
//            
//            
//        } completion:^(BOOL finished) {
//            
//            
//        }];
//    }
//    else
//    {
        UIWindow *mainWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];

        UIViewController *sourceViewController = self.sourceViewController;
        UIViewController *destinationViewController = self.destinationViewController;
        
        UIGraphicsBeginImageContext(mainWindow.bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [sourceViewController.view.layer renderInContext:context];
        UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *img = [[UIImageView alloc] initWithImage:screenShot];
        
        [destinationViewController.view addSubview:img];
            [sourceViewController presentViewController:destinationViewController animated:NO completion:^{
                
                [UIView animateWithDuration:0.5f animations:^{
                    
                    CGRectSetY(img, 1000);
                    
                } completion:^(BOOL finished) {
                  
                    [img removeFromSuperview];
                    
                }];
                
            }];
//    }
}

@end
