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
#import "GLPUserDao.h"


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
        GLPNotification *notification = [GLPNotificationDaoParser createFromResultSet:resultSet inDb:db];
        [result addObject:notification];
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
    
    //Parse the custom parameters.
    int groupRemoteKey = [GLPNotificationDao parseGroupRemoteKeyWithEntity:entity];
    
    
    [db executeUpdateWithFormat:@"insert into notifications (remoteKey, seen, date, type, post_remote_key, user_remote_key, group_remote_key) values(%d, %d, %d, %d, %d, %d, %d)",
                      entity.remoteKey,
                        entity.seen,
                        date,
                      entity.notificationType,
                      entity.postRemoteKey,
                      entity.user.remoteKey,
                        groupRemoteKey];
    
    entity.key = [db lastInsertRowId];

    
    //Add the user to users table.
    [GLPUserDao saveIfNotExist:entity.user db:db];
}

+(int)parseGroupRemoteKeyWithEntity:(GLPNotification *)entity
{
    if(entity.customParams)
    {
        NSString *groupRemoteKey = entity.customParams[@"network"];
        
        return [groupRemoteKey integerValue];
    }
    
    return 0;

}

+ (NSMutableArray *)findNotifications:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from notifications order by date desc"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        GLPNotification *notification = [GLPNotificationDaoParser createFromResultSet:resultSet inDb:db];
        [result addObject:notification];
    }
    
    return result;
}

+ (NSMutableArray *)findUnreadNotifications:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from notifications where seen=0 order by date desc"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        GLPNotification *notification = [GLPNotificationDaoParser createFromResultSet:resultSet inDb:db];
        [result addObject:notification];
    }
    
    return result;
}

+ (NSInteger)unreadNotificationsCount:(FMDatabase *)db
{
    return [db intForQuery:@"select count(key) from notifications where seen = 0"];
}

+ (NSInteger)countReadNotificationsInDb:(FMDatabase *)db
{
    return [db intForQuery:@"select count(key) from notifications where seen = 1"];
}

+ (void)markNotificationsRead:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"update notifications set seen=1"];
}


+(void)updateNotificationType:(GLPNotification *)notification inDb:(FMDatabase*)db
{
    NSAssert(notification.key != 0, @"Notification key required");
    [db executeUpdateWithFormat:@"update notifications set type=%d where key=%d", notification.notificationType, notification.key];
}

+(void)deleteNotification:(GLPNotification *)notification inDb:(FMDatabase*)db
{
    NSAssert(notification.key != 0, @"Notification key required");
    [db executeUpdateWithFormat:@"delete from notifications where key=%d", notification.key];
}

+ (void)deleteAll:(FMDatabase*)db
{
    [db executeUpdateWithFormat:@"delete from notifications"];
}


@end