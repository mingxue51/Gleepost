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

+ (NSInteger)countReadNotificationsInDb:(FMDatabase *)db;
+(void)deleteTableWithDb:(FMDatabase*)db;
+(void)deleteNotifications:(FMDatabase*)db withNumber:(int)number;

// new version
+ (NSMutableArray *)findNotifications:(FMDatabase *)db;
+ (NSInteger)unreadNotificationsCount:(FMDatabase *)db;
+ (void)markNotificationsRead:(FMDatabase *)db;
+ (void)deleteAll:(FMDatabase*)db;

@end
