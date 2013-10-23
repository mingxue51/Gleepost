//
//  GLPConversationDao.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPConversationDao.h"
#import "DatabaseManager.h"
#import "GLPConversationDaoParser.h"
#import "FMResultSet.h"

@implementation GLPConversationDao

+ (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPConversation *conversation;
    
    [[DatabaseManager sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        conversation = [GLPConversationDao findByRemoteKey:remoteKey db:db];
    }];
    
    return conversation;
}

+ (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations where remoteKey=%d limit 1", remoteKey];
    
    if(![resultSet next]) {
        return nil;
    }
    
    return [GLPConversationDaoParser createFromResultSet:resultSet];
}

+ (NSArray *)findAllOrderByDate:(FMDatabase *)db;
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations order by lastUpdate DESC"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPConversationDaoParser createFromResultSet:resultSet]];
    }
    
    return result;
}

+ (void)save:(GLPConversation *)entity db:(FMDatabase *)db
{
    int date = [entity.lastUpdate timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"insert into conversations(remoteKey, lastMessage, lastUpdate, title, notificationsCount) values(%d, %@, %d, %@, %d)",
     entity.remoteKey,
     entity.lastMessage,
     date,
     entity.title,
     entity.notificationsCount];
    
    entity.key = [db lastInsertRowId];
}

+ (void)deleteAll:(FMDatabase *)db
{
    [db executeUpdate:@"delete from conversations"];
}


@end
