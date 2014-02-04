//
//  CustomPushTransitioningDelegate.h
//  Gleepost
//
//  Created by Σιλουανός on 4/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomPushTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

-(id)initWithFirstController:(UIViewController*)first andDestinationController:(UIViewController*)destination;

@end
