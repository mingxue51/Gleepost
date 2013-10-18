//
//  GLPMessageDao.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPMessageDao.h"
#import "FMResultSet.h"
#import "GLPMessageDaoParser.h"
#import "DatabaseManager.h"

@implementation GLPMessageDao

+ (NSArray *)findAllOrderByDateForConversation:(GLPConversation *)conversation
{
    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from messages where conversation_key=%d order by date ASC", conversation.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    while ([resultSet next]) {
        [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet]];
    }
    
    return result;
}

+ (NSArray *)findAllOrderByDateForConversation:(GLPConversation *)conversation afterInsertingNewMessages:(NSArray *)newMessages
{
    [[DatabaseManager sharedInstance].database beginTransaction];
    for(GLPMessage *message in newMessages) {
        [GLPMessageDao save:message];
    }
    
    NSArray *result = [GLPMessageDao findAllOrderByDateForConversation:conversation];
    
    [[DatabaseManager sharedInstance].database commit];
    
    return result;
}

+ (void)save:(GLPMessage *)entity
{
    int date = [entity.date timeIntervalSince1970];
    [[DatabaseManager sharedInstance].database executeUpdateWithFormat:@"insert into messages (remoteKey, content, date, sendStatus, author_key, conversation_key) values(%d, %@, %d, %d, %d, %d)",
            entity.remoteKey,
            entity.content,
            date,
            entity.sendStatus,
            entity.author.remoteKey,
            entity.conversation.remoteKey];
    
    entity.key = [[DatabaseManager sharedInstance].database lastInsertRowId];
}

+ (void)update:(GLPMessage *)entity
{
    NSAssert(entity.key != 0, @"Cannot save entity without key");
    
    int date = [entity.date timeIntervalSince1970];
    
    [[DatabaseManager sharedInstance].database executeUpdateWithFormat:@"update messages set remoteKey=%d, content=%@, date=%d, sendStatus=%d, author_key=%d, conversation_key=%d where key=%d",
     entity.remoteKey,
     entity.content,
     date,
     entity.sendStatus,
     entity.author.remoteKey,
     entity.conversation.remoteKey,
     entity.key];
}

@end
