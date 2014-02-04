//
//  CustomPushTransitioning.h
//  Gleepost
//
//  Created by Σιλουανός on 4/2/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomPushTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

-(id)initWithFirstController:(UIViewController*)first andDestinationController:(UIViewController*)destination;

@property (nonatomic, assign) BOOL isPresenting;

@end
