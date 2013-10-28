//
//  GLPLiveConversationDao.m
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversationDao.h"
#import "GLPLiveConversationDaoParser.h"

@implementation GLPLiveConversationDao


+ (NSArray *)findAllOrderByDate:(FMDatabase *)db;
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from live_conversations order by lastUpdate DESC"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next])
    {
        [result addObject:[GLPLiveConversationDaoParser createFromResultSet:resultSet]];
    }
    
    return result;
}


+ (void)save:(GLPLiveConversation *)entity db:(FMDatabase *)db
{
    int date = [entity.lastUpdate timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"insert into live_conversations(remoteKey, lastUpdate, title, unread, timeStarted) values(%d, %d, %@, %d, %d)",
     entity.remoteKey,
     date,
     entity.title,
     entity.hasUnreadMessages,
     entity.timeStarted];
    
    entity.key = [db lastInsertRowId];
}

+(BOOL)deleteLiveConversationWithId:(int)conversationId db:(FMDatabase* )db
{
    return [db executeUpdateWithFormat:@"delete from live_conversations where key=%d",conversationId];
}

+ (void)update:(GLPLiveConversation *)entity db:(FMDatabase *)db
{
    //TODO: Changed.
    NSAssert(entity.remoteKey != 0, @"Cannot update entity without key");
    
    int date = [entity.lastUpdate timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"update live_conversations set remoteKey=%d, lastMessage=%@, lastUpdate=%d, title=%@, unread=%d, timeStarted=%d where key=%d",
     entity.remoteKey,
     date,
     entity.title,
     entity.hasUnreadMessages,
     entity.timeStarted,
     entity.key];
}

+ (void)deleteAll:(FMDatabase *)db
{
    [db executeUpdate:@"delete from live_conversations"];
}

@end
