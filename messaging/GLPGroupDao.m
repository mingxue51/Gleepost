//
//  GLPGroupDao.m
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupDao.h"
#import "DatabaseManager.h"
#import "GLPGroupDaoParser.h"
#import "GLPPostDao.h"

@implementation GLPGroupDao


+ (GLPGroup *)findByRemoteKey:(int)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from groups where remoteKey=%d", remoteKey];
    
    GLPGroup *group = nil;
    
    if([resultSet next]) {
        
        group = [GLPGroupDaoParser createFromResultSet:resultSet inDb:db];
    }
    
    return group;
}


+ (NSArray *)findGroupsdb:(FMDatabase *)db
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from groups"];
    
    while ([resultSet next])
    {
        GLPGroup *currentGroup = [GLPGroupDaoParser createFromResultSet:resultSet inDb:db];
    
        [groups addObject: currentGroup];
        
    }
    
    return groups;
}

+ (NSArray *)findRemoteGroupsdb:(FMDatabase *)db
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];

//    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from groups where send_status = %d order by remoteKey asc", kSendStatusSent];

    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from groups where send_status = %d order by last_activity desc", kSendStatusSent];
    
    while ([resultSet next])
    {
        GLPGroup *currentGroup = [GLPGroupDaoParser createFromResultSet:resultSet inDb:db];
        
        [groups addObject: currentGroup];
        
    }
    return groups;
}

+(NSArray *)findGroups
{
    __block NSArray *groups = [[NSMutableArray alloc] init];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        groups = [GLPGroupDao findGroupsdb:db];
        
    }];
    
    return groups;
}

+(NSArray *)findRemoteGroups
{
    __block NSArray *groups = [[NSMutableArray alloc] init];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        groups = [GLPGroupDao findRemoteGroupsdb:db];
        
    }];
    
    return groups;
}

+ (NSInteger)saveIfNotExist:(GLPGroup *)entity
{
    __block NSInteger key = 0;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        key = [GLPGroupDao saveIfNotExist:entity db:db];
    }];
    
    return key;
}

+ (NSInteger)saveIfNotExist:(GLPGroup *)entity db:(FMDatabase *)db
{
    GLPGroup *group = [GLPGroupDao findByRemoteKey:entity.remoteKey db:db];
    
    if(group == nil)
    {
        [GLPGroupDao save:entity inDb:db];
        entity.key = [db lastInsertRowId];
        
        return entity.key;
    }
    
    return group.key;
}

+ (void)save:(GLPGroup *)entity inDb:(FMDatabase *)db
{
    int date = [entity.lastActivity timeIntervalSince1970];
    
    if(entity.remoteKey == 0)
    {
        [db executeUpdateWithFormat:@"insert into groups (title, description, image_url, send_status, date, last_activity, user_remote_key, loggedin_user_role_key, conversation_remote_key, privacy, members_count) values(%@, %@, %@, %d, %d, %d, %d, %d, %d, %d, %d)",
         entity.name,
         entity.groupDescription,
         entity.groupImageUrl,
         entity.sendStatus,
         0,
         date,
         entity.author.remoteKey,
         entity.loggedInUser.roleLevel,
         entity.conversationRemoteKey,
         entity.privacy,
         entity.membersCount];
    }
    else
    {
        [db executeUpdateWithFormat:@"insert into groups (remoteKey, title, description, image_url, send_status, date, last_activity, user_remote_key, loggedin_user_role_key, conversation_remote_key, privacy, members_count) values(%d, %@, %@, %@, %d, %d, %d, %d, %d, %d, %d, %d)",
         entity.remoteKey,
         entity.name,
         entity.groupDescription,
         entity.groupImageUrl,
         entity.sendStatus,
         0,
         date,
         entity.author.remoteKey,
         entity.loggedInUser.roleLevel,
         entity.conversationRemoteKey,
         entity.privacy,
         entity.membersCount];
    }
    
    entity.key = [db lastInsertRowId];
}

+(void)remove:(GLPGroup *)group
{
    NSAssert(group.remoteKey != 0, @"Remote key must not be 0.");
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPGroupDao remove:group inDb:db];
    }];
}

+(void)remove:(GLPGroup *)group inDb:(FMDatabase *)db
{
    BOOL removed = [db executeUpdateWithFormat:@"delete from groups where remoteKey=%d", group.remoteKey];
    
    [GLPPostDao deletePostsWithGroupRemoteKey:group.remoteKey db:db];
    
    DDLogInfo(@"Group with key %ld removed status %d.", (long)group.remoteKey, removed);
}

+(void)updateGroupSendingData:(GLPGroup *)entity db:(FMDatabase *)db
{
    BOOL success = NO;
    
    if(entity.remoteKey != 0)
    {
        success = [db executeUpdateWithFormat:@"update groups set remoteKey=%d, send_status=%d, image_url=%@ where key=%d",
                   entity.remoteKey,
                   entity.sendStatus,
                   entity.groupImageUrl,
                   entity.key];
        
    } else
    {
        success = [db executeUpdateWithFormat:@"update groups set send_status=%d, image_url=%@ where key=%d",
                   entity.sendStatus,
                   entity.groupImageUrl,
                   entity.key];
    }
    
}

+(void)updateGroupWithRemoteKey:(GLPGroup *)entity db:(FMDatabase *)db
{
    BOOL success = NO;
    

    success = [db executeUpdateWithFormat:@"update groups set image_url=%@ where remoteKey=%d",
                   entity.groupImageUrl,
                   entity.remoteKey];
        
    
    DDLogInfo(@"Group with title %@ and url %@ updated successfully", entity.name, entity.groupImageUrl);
}


+(void)updateGroupSendingData:(GLPGroup *)entity
{
    NSAssert(entity.key != 0, @"Update group entity without key");
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPGroupDao updateGroupSendingData:entity db:db];
        
    }];
}

+(void)updateGroup:(GLPGroup *)entity
{
    NSAssert(entity.remoteKey != 0, @"Update group entity without remote key");
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [self updateGroupWithRemoteKey:entity db:db];
    }];

}

+(void)saveGroups:(NSArray *)groups
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
//        [self cleanTable:db];
        
        for(GLPGroup *group in groups)
        {
            group.sendStatus = kSendStatusSent;
            [GLPGroupDao saveIfNotExist:group db:db];
        }
        
    }];
}

+(void)cleanTable:(FMDatabase*)db
{
    [db executeUpdateWithFormat:@"delete from groups"];
}


@end