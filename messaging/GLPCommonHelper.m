//
//  GLPCommonHelper.m
//  Gleepost
//
//  Created by Lukas on 2/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCommonHelper.h"

@implementation GLPCommonHelper

+ (NSString *)applicationStateToString:(UIApplicationState)applicationState
{
    NSString *state;
    if(applicationState == UIApplicationStateActive) {
        state = @"Active";
    } else if (applicationState == UIApplicationStateInactive) {
        state = @"Inactive";
    } else if(applicationState == UIApplicationStateBackground) {
        state = @"Background";
    } else {
        state = @"Undefined";
    }
    
    return state;
}

@end
