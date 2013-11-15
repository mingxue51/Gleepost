//
//  UIViewController+GAI.m
//  Gleepost
//
//  Created by Tanmay Khandelwal on 14/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "UIViewController+GAI.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@implementation UIViewController (GAI)

- (void)sendViewToGAI:(NSString *)view {
    // Initialize tracker
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GLP_GAI_TRACK_ID];
    
    [tracker set:kGAIScreenName value:view];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
