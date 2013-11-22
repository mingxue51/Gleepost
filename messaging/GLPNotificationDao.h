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
+ (void)updateSeenStatus:(GLPNotification *)entity inDb:(FMDatabase *)db;
+ (void)save:(GLPNotification *)entity inDb:(FMDatabase *)db;
+ (NSInteger)countUnreadNotificationsInDb:(FMDatabase *)db;
+(void)deleteTableWithDb:(FMDatabase*)db;
+(void)deleteNotifications:(FMDatabase*)db withNumber:(int)number;

@end
