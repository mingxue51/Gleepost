//
//  NotificationsManager.m
//  Gleepost
//
//  Created by Σιλουανός on 27/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPNotificationManager.h"
#import "GLPNotificationDao.h"
#import "DatabaseManager.h"
#import "SessionManager.h"
#import "WebClient.h"

@implementation GLPNotificationManager

+ (void)loadNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback
{
    __block NSArray *localEntities;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPNotificationDao findNotificationsForUser:[SessionManager sharedInstance].user inDb:db];
    }];
    
    callback(YES, localEntities);
}

+ (void)markNotificationsRead:(NSArray *)notifications callback:(void (^)(BOOL success, NSArray *notifications))callback
{
    NSLog(@"Mark notifications read");
    
    // take the most recent unread notification, order being most recent DESC (or should be hopefully!)
    GLPNotification *unreadNotification = nil;
    for(GLPNotification *n in notifications) {
        if(!n.seen) {
            unreadNotification = n;
            break;
        }
    }
    
    if(!unreadNotification) {
        NSLog(@"No unread notifications");
        callback(YES, nil);
    }
    
    [[WebClient sharedInstance] markNotificationRead:unreadNotification callback:^(BOOL success, NSArray *newNotifications) {
        
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        // mark previous notifications as read
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            for(GLPNotification *notification in notifications) {
                if(!notification.seen) {
                    notification.seen = YES;
                    [GLPNotificationDao updateSeenStatus:notification inDb:db];
                }
            }
        }];
        
        if(!newNotifications || newNotifications.count == 0) {
            callback(YES, nil);
            return;
        }
        
        // save new notifications
        [GLPNotificationManager saveNotifications:newNotifications];
        callback(YES, newNotifications);
    }];
}

+ (NSInteger)getNotificationsCount
{
    __block int count = 0;
    [DatabaseManager run:^(FMDatabase *db) {
        count = [GLPNotificationDao countUnreadNotificationsInDb:db];
    }];
    
    return count;
}

+ (void)saveNotifications:(NSArray *)notifications
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        for(GLPNotification *notification in notifications) {
            [GLPNotificationDao save:notification inDb:db];
        }
    }];
}


@end
