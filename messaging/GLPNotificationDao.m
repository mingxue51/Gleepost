//
//  GLPNotificationDao.m
//  Gleepost
//
//  Created by Lukas on 11/13/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPNotificationDao.h"
#import "GLPNotificationDaoParser.h"


@implementation GLPNotificationDao

+ (NSArray *)findNotificationsForUser:(GLPUser *)user inDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from notifications where user_remote_key = %d order by remoteKey desc", user.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPNotificationDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (void)save:(GLPNotification *)entity inDb:(FMDatabase *)db
{
    int date = [entity.date timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"insert into posts (remoteKey, notification_type, date, post_remote_key, user_remote_key) values(%d, %d, %d, %d, %d)",
                      entity.remoteKey,
                      entity.notificationType,
                      date,
                      entity.postRemoteKey,
                      entity.user.remoteKey];
    
    entity.key = [db lastInsertRowId];
}

@end