//
//  UIViewController+GAI.h
//  Gleepost
//
//  Created by Tanmay Khandelwal on 14/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//
//  Category on UIViewController to track view controller
//  interactions via Google Analytics for iOS
//

#import <UIKit/UIKit.h>

@interface UIViewController (GAI)

// Can be used to track viewWillAppear
- (void)sendViewToGAI:(NSString *)view;

@end
