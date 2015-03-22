//
//  GLPNotificationDao.h
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "GLPNotification.h"

@interface GLPNotificationDao : NSObject

+ (NSArray *)findNotificationsForUser:(GLPUser *)user inDb:(FMDatabase *)db;
+ (NSArray *)findUnreadNotificationsInDb:(FMDatabase *)db;
+ (void)updateSeenStatus:(GLPNotification *)entity inDb:(FMDatabase *)db;
+ (void)save:(GLPNotification *)entity inDb:(FMDatabase *)db;
+ (void)saveIfNeeded:(GLPNotification *)entity db:(FMDatabase *)db;
+ (void)saveNotifications:(NSArray *)notifications;

+ (NSInteger)countReadNotificationsInDb:(FMDatabase *)db;
//+(void)deleteNotifications:(FMDatabase*)db withNumber:(int)number;

// new version
+ (NSMutableArray *)findNotifications:(FMDatabase *)db;
+ (NSMutableArray *)findUnreadNotifications:(FMDatabase *)db;
+ (NSInteger)unreadNotificationsCount:(FMDatabase *)db;
+ (void)markNotificationsRead:(FMDatabase *)db;
+(void)updateNotificationType:(GLPNotification *)notification inDb:(FMDatabase*)db;
+(void)deleteNotification:(GLPNotification *)notification inDb:(FMDatabase*)db;
+ (void)deleteAll:(FMDatabase*)db;

@end
