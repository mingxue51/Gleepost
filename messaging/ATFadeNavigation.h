//
//  ATNavigationCategories.h
//  Gleepost
//
//  Created by Σιλουανός on 28/5/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATFadeNavigation : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
