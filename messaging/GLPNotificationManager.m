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
#import "NSNotificationCenter+Utils.h"
#import "GLPLiveGroupManager.h"

@implementation GLPNotificationManager

+ (void)loadNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback
{
//    __block NSArray *localEntities;
//    [DatabaseManager run:^(FMDatabase *db) {
//        localEntities = [GLPNotificationDao findNotificationsForUser:[SessionManager sharedInstance].user inDb:db];
//    }];
    __block NSArray *localEntities;
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        localEntities = [GLPNotificationDao findNotificationsForUser:[SessionManager sharedInstance].user inDb:db];
    }];
    
    callback(YES, localEntities);
}

+(void)loadUnreadnotificationsWithCallback:(void (^) (BOOL success, NSArray *unreadNotifications))callback
{
//    __block NSArray *localEntities;
//    
//    [DatabaseManager run:^(FMDatabase *db) {
//        localEntities = [GLPNotificationDao findUnreadNotificationsInDb:db];
//    }];
    
    __block NSArray *localEntities;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        localEntities = [GLPNotificationDao findUnreadNotificationsInDb:db];
    }];
    
    callback(YES, localEntities);
}



/**
 Removes notifications that are already saved and presented in the view controller.
 
 @param incomingNotifications the new notifications from the server.
 
 @return the new notifications.
 
 */
+(NSArray*)cleanNotificationsArray:(NSArray*)incomingNotifications
{
    __block NSMutableArray *finalNotifications = [[NSMutableArray alloc] init];
    __block NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    
    [GLPNotificationManager loadUnreadnotificationsWithCallback:^(BOOL success, NSArray *unreadNotifications) {
       
//        NSMutableSet *incomingNotificationsSet = [NSMutableSet setWithArray: incomingNotifications];
//        NSSet *unreadNotificationsSet = [NSSet setWithArray: unreadNotifications];
//        [incomingNotificationsSet intersectSet: unreadNotificationsSet];
//        removeArray = [incomingNotificationsSet allObjects];
        
        for(GLPNotification *inN in incomingNotifications)
        {
            for(GLPNotification *unN in unreadNotifications)
            {
                if(inN.remoteKey == unN.remoteKey)
                {
                    [removeArray addObject:unN];
                }
            }
        }
        
        
    }];
    
    finalNotifications = incomingNotifications.mutableCopy;
    
    for(GLPNotification *n in removeArray)
    {
        [incomingNotifications indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            
            if(((GLPNotification *)obj).remoteKey == n.remoteKey)
            {
                [finalNotifications removeObject:(GLPNotification*)obj];
            }
            
            return ((GLPNotification *)obj).remoteKey == n.remoteKey;
        }];
        
    }
    
    return finalNotifications;
}

//+ (void)markNotificationsRead:(NSArray *)notifications callback:(void (^)(BOOL success, NSArray *notifications))callback
//{
//    NSLog(@"Mark notifications read");
//    
//    // take the most recent unread notification, order being most recent DESC (or should be hopefully!)
//    GLPNotification *unreadNotification = nil;
//    for(GLPNotification *n in notifications) {
//        if(!n.seen) {
//            unreadNotification = n;
//            break;
//        }
//    }
//    
//    if(!unreadNotification) {
//        NSLog(@"No unread notifications");
//        callback(YES, nil);
//    }
//    
//    [[WebClient sharedInstance] markNotificationRead:unreadNotification callback:^(BOOL success, NSArray *newNotifications) {
//        
//        if(!success) {
//            callback(NO, nil);
//            return;
//        }
//        
//        // mark previous notifications as read
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            for(GLPNotification *notification in notifications) {
//                if(!notification.seen) {
//                    notification.seen = YES;
//                    [GLPNotificationDao updateSeenStatus:notification inDb:db];
//                }
//            }
//        }];
//        
//        if(!newNotifications || newNotifications.count == 0) {
//            callback(YES, nil);
//            return;
//        }
//        
//        // save new notifications
//        [GLPNotificationManager saveNotifications:newNotifications];
//        callback(YES, newNotifications);
//    }];
//}

+ (NSMutableArray *)notifications
{
//    __block NSMutableArray *notifications;
//    [DatabaseManager run:^(FMDatabase *db) {
//        notifications = [GLPNotificationDao findNotifications:db];
//    }];
    
    __block NSMutableArray *notifications;
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        notifications = [GLPNotificationDao findNotifications:db];
    }];
    
    return notifications;
}

+ (NSMutableArray *)unreadNotifications
{
//    __block NSMutableArray *notifications;
//    [DatabaseManager run:^(FMDatabase *db) {
//        notifications = [GLPNotificationDao findUnreadNotifications:db];
//    }];
    
    __block NSMutableArray *notifications;
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        notifications = [GLPNotificationDao findUnreadNotifications:db];
    }];
    
    return notifications;
}


+ (NSInteger)unreadNotificationsCount
{
//    __block int count = 0;
//    [DatabaseManager run:^(FMDatabase *db) {
//        count = [GLPNotificationDao unreadNotificationsCount:db];
//    }];
    
    __block int count = 0;
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        count = [GLPNotificationDao unreadNotificationsCount:db];
    }];

    
    return count;
}

+ (void)markAllNotificationsRead
{
    __block NSArray *unreadNotifications = nil;

    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        unreadNotifications = [GLPNotificationDao findUnreadNotifications:db];
        
        
        if(unreadNotifications.count != 0)
        {
            GLPNotification *lastNotification = [unreadNotifications objectAtIndex:0];
            
            DDLogInfo(@"Last notification with content: %d", lastNotification.notificationType);
            
            [[WebClient sharedInstance] markNotificationsReadWithLastNotificationRemoteKey:lastNotification.remoteKey withCallbackBlock:^(BOOL success) {
                
                if(success)
                {
                    DDLogInfo(@"Notifications mark as read.");
                }
                
            }];
            
            [GLPNotificationDao markNotificationsRead:db];
        }

    }];
}

+ (void)ignoreNotification:(GLPNotification *)notification
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPNotificationDao deleteNotification:notification inDb:db];
    }];
}

+ (void)acceptNotification:(GLPNotification *)notification
{
    notification.notificationType = kGLPNotificationTypeAcceptedYou;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPNotificationDao updateNotificationType:notification inDb:db];
    }];
}

// Save notification from web socket event
// Executed in background
+ (void)saveNotification:(GLPNotification *)notification
{
    DDLogInfo(@"Save notification with remote key %d", notification.remoteKey);
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPNotificationDao save:notification inDb:db];
    }];
    
    [[GLPLiveGroupManager sharedInstance] loadGroupsIfNeededWithNewNotification:notification];
    
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_NEW_NOTIFICATION object:self userInfo:@{@"new_notification": notification}];
}


+ (void)saveNotifications:(NSArray *)notifications
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
//        if([GLPNotificationDao countReadNotificationsInDb:db]>10)
//        {
//            [GLPNotificationDao deleteNotifications:db withNumber:notifications.count];
//        }
            
        for(GLPNotification *notification in notifications)
        {
            [GLPNotificationDao save:notification inDb:db];
            DDLogInfo(@"New notifications after become active. %@", notification);
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_NEW_NOTIFICATION object:nil userInfo:nil];
        }
    }];
}

+ (void)clearAllNotifications
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPNotificationDao deleteAll:db];
    }];
}

+(void)fetchNotificationsFromServerWithCallBack:(void (^) (BOOL success, NSArray *notifications))callback
{
    [[WebClient sharedInstance] getNotificationsWithCallback:^(BOOL success, NSArray *notifications) {
        if(success) {
            NSLog(@"New notifications from get notifications request: %d", notifications.count);
            
            if(notifications.count > 0)
            {
                //Check if the same notification exist in database and if it is unread. If yes the don't call GLPNewNotifications.
                NSArray* finalNotifications = [GLPNotificationManager cleanNotificationsArray:notifications];
                
                if(finalNotifications.count > 0)
                {
                    //Save notifications after the launch of the app.
                    [GLPNotificationManager saveNotifications:finalNotifications];
                }
                else
                {
                    DDLogInfo(@"No new final notifications.");
                }
                
                callback(success, notifications);
            }
            else
            {
                callback(YES, [[NSArray alloc] init]);
            }
        }
        else
        {
            callback(NO, nil);
        }
    }];
    
}

+ (void)loadNotificationsWithLocalCallback:(void (^) (BOOL success, NSArray *notifications))localCallback andRemoteCallback:(void (^) (BOOL success, NSArray *remoteNotifications))remoteCallback
{
    
    __block NSArray *localNotifications = nil;
    
    [GLPNotificationManager loadNotificationsWithCallback:^(BOOL success, NSArray *notifications) {
       
        DDLogInfo(@"Local notifications count: %ld", (unsigned long)notifications.count);
        
        localNotifications = notifications;
        
        localCallback(success, localNotifications);
        
    }];
    
    
    [[WebClient sharedInstance] getAllNotificationsWithCallback:^(BOOL success, NSArray *notifications) {
       
        if(success)
        {
            
            DDLogInfo(@"Remote notifications count: %ld", (unsigned long)notifications.count);
            
            //Save notifications from server.
            [GLPNotificationDao saveNotifications:notifications];
            
            remoteCallback(success, notifications);
        }
        
        
    }];
}


@end