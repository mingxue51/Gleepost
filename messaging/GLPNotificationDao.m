//
//  GLPNotificationDao.m
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPNotificationDao.h"
#import "GLPNotificationDaoParser.h"
#import "FMDatabaseAdditions.h"


@implementation GLPNotificationDao

+ (NSArray *)findNotificationsForUser:(GLPUser *)user inDb:(FMDatabase *)db
{
    //FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from notifications where user_remote_key = %d order by remoteKey desc", user.remoteKey];
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from notifications order by date desc"];

    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPNotificationDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (NSArray *)findUnreadNotificationsInDb:(FMDatabase *)db
{
    //FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from notifications where user_remote_key = %d order by remoteKey desc", user.remoteKey];
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from notifications where seen = 0"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPNotificationDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (void)updateSeenStatus:(GLPNotification *)entity inDb:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Update entity without key");
    
    [db executeUpdateWithFormat:@"update notifications set seen=%d where key=%d",
        entity.seen,
        entity.key];
}

+ (void)save:(GLPNotification *)entity inDb:(FMDatabase *)db
{
    int date = [entity.date timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"insert into notifications (remoteKey, seen, date, type, post_remote_key, user_remote_key) values(%d, %d, %d, %d, %d, %d)",
                      entity.remoteKey,
                        entity.seen,
                        date,
                      entity.notificationType,
                      entity.postRemoteKey,
                      entity.user.remoteKey];
    
    entity.key = [db lastInsertRowId];
}

+ (NSInteger)countUnreadNotificationsInDb:(FMDatabase *)db
{
    return [db intForQuery:@"select count(key) from notifications where seen = 0"];
}

+ (NSInteger)countReadNotificationsInDb:(FMDatabase *)db
{
    return [db intForQuery:@"select count(key) from notifications where seen = 1"];
}

+(void)deleteNotifications:(FMDatabase*)db withNumber:(int)number
{
    
    /**
     DELETE FROM ranking WHERE id NOT IN (
     SELECT id FROM ranking ORDER BY score DESC LIMIT 100);
     */
    
    BOOL s = [db executeUpdateWithFormat:@"delete from notifications where key in (select key from notifications where seen = 1 order by date desc limit %d)",number];
    NSLog(@"Some notifications are deleted: %d",s);
}

+(void)deleteTableWithDb:(FMDatabase*)db
{
    [db executeUpdateWithFormat:@"delete from notifications"];
}


@end