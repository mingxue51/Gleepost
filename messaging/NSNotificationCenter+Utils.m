//
//  NSNotificationCenter+Utils.m
//  Gleepost
//
//  Created by Lukas on 11/24/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NSNotificationCenter+Utils.h"

@implementation NSNotificationCenter (Utils)

-(void)postNotificationOnMainThread:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

-(void)postNotificationNameOnMainThread:(NSString *)name object:(id)object
{
    [self postNotificationNameOnMainThread:name object:object userInfo:nil];
}

-(void)postNotificationNameOnMainThread:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self postNotificationName:name object:object userInfo:userInfo];
    });
}

@end
