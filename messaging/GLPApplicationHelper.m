//
//  GLPCommonHelper.m
//  Gleepost
//
//  Created by Lukas on 2/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPApplicationHelper.h"
#import "GLPTimelineViewController.h"

@implementation GLPApplicationHelper

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

+ (BOOL)isTheNextViewCampusWall:(NSArray *)viewControllersStuck
{    
    if(viewControllersStuck.count == 1)
    {
        UIViewController *campusWall = [viewControllersStuck objectAtIndex:0];
        
        if([campusWall isKindOfClass:[GLPTimelineViewController class]])
        {
            return YES;
        }
    }
    
    return NO;
}

@end
