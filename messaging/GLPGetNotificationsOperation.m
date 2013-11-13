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
#import "GLPNotificationDao.h"

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
                [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                    for(GLPNotification *notification in notifications) {
                        [GLPNotificationDao save:notification inDb:db];
                    }
                }];
            }
        }
    }];
    
    // sleep for some times
    [NSThread sleepForTimeInterval:30];
    
    [self startRequest];
}


@end
