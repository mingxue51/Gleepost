//
//  ATPopUpAfterGoingView.h
//  Gleepost
//
//  Created by Silouanos on 14/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATPopUpAfterGoingView : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
