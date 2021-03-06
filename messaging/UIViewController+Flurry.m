//
//  UIViewController+Flurry.m
//  Gleepost
//
//  Created by Tanmay Khandelwal on 20/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "UIViewController+Flurry.h"
#import "Flurry.h"

@implementation UIViewController (Flurry)

- (void)sendViewToFlurry:(NSString *)view {
    [Flurry logEvent:view];
}

-(void)sendView:(NSString *)view withId:(NSInteger)remoteKey
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)remoteKey], @"Key", nil];
    [Flurry logEvent:view withParameters:params];
}

@end
