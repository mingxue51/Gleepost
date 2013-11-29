//
//  GLPGetNotificationsOperation.m
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPGetNotificationsOperation.h"
#import "WebClient.h"
#import "DatabaseManager.h"
#import "GLPNotification.h"
#import "GLPNotificationManager.h"
#import "NSNotificationCenter+Utils.h"

@interface GLPGetNotificationsOperation()

@end

@implementation GLPGetNotificationsOperation

- (void)main {
    @autoreleasepool {
        [self startRequest];
    }
}

- (void)startRequest
{
    if(self.isCancelled) {
        NSLog(@"Get notifications operation cancelled");
        return;
    }
    
    NSLog(@"Start get notifications request");
    
    [[WebClient sharedInstance] synchronousGetNotificationsWithCallback:^(BOOL success, NSArray *notifications) {
        if(success) {
            NSLog(@"New notifications from get notifications request: %d", notifications.count);
            
            if(notifications.count > 0) {
                
                //Check if the same notification exist in database and if it is unread. If yes the don't call GLPNewNotifications.
                NSArray* finalNotifications = [GLPNotificationManager cleanNotificationsArray:notifications];
                
                if(finalNotifications.count > 0)
                {
                    //Don't do anything.
                    [GLPNotificationManager saveNotifications:finalNotifications];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPNewNotifications" object:nil userInfo:@{@"count":[NSNumber numberWithInt:notifications.count]}];
                }
                else
                {

                }
            }
        }
    }];
    
    // sleep for some times
    [NSThread sleepForTimeInterval:RELOAD_NOTIFICATIONS_INTERVAL_S];
    
    [self startRequest];
}


@end
