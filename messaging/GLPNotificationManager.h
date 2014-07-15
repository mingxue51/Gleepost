//
//  NotificationsManager.h
//  Gleepost
//
//  Created by Σιλουανός on 27/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPNotification.h"

@interface GLPNotificationManager : NSObject

+ (void)loadNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback;
+ (NSArray*)cleanNotificationsArray:(NSArray*)incomingNotifications;

// New
+ (NSMutableArray *)notifications;
+ (NSMutableArray *)unreadNotifications;
+ (NSInteger)unreadNotificationsCount;
+ (void)markAllNotificationsRead;
+ (void)ignoreNotification:(GLPNotification *)notification;
+ (void)acceptNotification:(GLPNotification *)notification;
+ (void)saveNotification:(GLPNotification *)notification;
+ (void)clearAllNotifications;
+(void)fetchNotificationsFromServerWithCallBack:(void (^) (BOOL success, NSArray *notifications))callback;

@end
