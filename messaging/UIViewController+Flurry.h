//
//  UIViewController+Flurry.h
//  Gleepost
//
//  Created by Tanmay Khandelwal on 20/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//
//  Category on UIViewController to track view controller
//  interactions via Flurry Analytics for iOS
//

#import <UIKit/UIKit.h>

@interface UIViewController (Flurry)

// Can be used to track viewWillAppear
- (void)sendViewToFlurry:(NSString *)view;
-(void)sendView:(NSString *)view withId:(int)remoteKey;

@end
