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
    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from conversations where remoteKey=%d limit 1", remoteKey];
    
    if(![resultSet next]) {
        return nil;
    }
    
    return [GLPConversationDaoParser createFromResultSet:resultSet];
}

+ (NSArray *)findAllOrderByDate
{
    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from conversations order by lastUpdate DESC"];
    
    NSMutableArray *result = [NSMutableArray array];
    while ([resultSet next]) {
        [result addObject:[GLPConversationDaoParser createFromResultSet:resultSet]];
    }
    
    return result;
}

+ (void)save:(GLPConversation *)entity
{
    //NSString *participants = [[entity.participants valueForKeyPath:@"remoteKey"] componentsJoinedByString:@","];
    int date = [entity.lastUpdate timeIntervalSince1970];
    NSLog(@"save %@", entity.title);
    
    [[DatabaseManager sharedInstance].database executeUpdateWithFormat:@"insert into conversations(remoteKey, lastMessage, lastUpdate, title) values(%d, %@, %d, %@)",
     entity.remoteKey,
     entity.lastMessage,
     date,
     entity.title];
    
    entity.key = [[DatabaseManager sharedInstance].database lastInsertRowId];
}

+ (void)replaceAllConversationsWith:(NSArray *)conversations
{
    FMDatabase *database = [DatabaseManager sharedInstance].database;
    [database beginTransaction];
    [database executeUpdate:@"delete from conversations"];
    
    for (GLPConversation *conversation in conversations) {
        [GLPConversationDao save:conversation];
    }
    
    [database commit];
}

@end
