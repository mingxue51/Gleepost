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
+ (void)markNotificationsRead:(NSArray *)notifications callback:(void (^)(BOOL success, NSArray *notifications))callback;

+ (NSInteger)getNotificationsCount;
+(NSArray*)cleanNotificationsArray:(NSArray*)incomingNotifications;

+ (void)saveNotification:(GLPNotification *)notification;
+ (void)saveNotifications:(NSArray *)notifications;

@end
