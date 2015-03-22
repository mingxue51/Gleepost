//
//  GLPPostDaoParser.m
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPNotificationDaoParser.h"
#import "GLPEntityDaoParser.h"
#import "FMResultSet.h"
#import "GLPUserDao.h"

@implementation GLPNotificationDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPNotification *)entity inDb:(FMDatabase *)db
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.notificationType = [resultSet intForColumn:@"type"];
    entity.date = [resultSet dateForColumn:@"date"];
    entity.postRemoteKey = [resultSet intForColumn:@"post_remote_key"];
    entity.seen = [resultSet boolForColumn:@"seen"];
    
    int userRemoteKey = [resultSet intForColumn:@"user_remote_key"];
    
    entity.user = [GLPUserDao findByRemoteKey:userRemoteKey db:db];
    
    int groupRemoteKey = [resultSet intForColumn:@"group_remote_key"];
    
    NSString *groupRemoteKeyStr = [NSString stringWithFormat:@"%d", groupRemoteKey];
    
    entity.customParams = @{@"network" : groupRemoteKeyStr};
    
    entity.previewMessage = [resultSet stringForColumn:@"preview_message"];
}

+ (GLPNotification *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPNotification *entity = [[GLPNotification alloc] init];
    [GLPNotificationDaoParser parseResultSet:resultSet into:entity inDb:db];
    
    return entity;
}

@end
