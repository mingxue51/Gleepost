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
#import "GLPConversationDao.h"

@implementation GLPMessageDao

+ (NSArray *)findLastMessagesForConversation:(GLPConversation *)conversation
{
    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from messages where conversation_key=%d order by displayOrder DESC limit 20", conversation.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    while ([resultSet next]) {
        [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet]];
    }
    
    return [[result reverseObjectEnumerator] allObjects];
}

+ (NSArray *)findAllOrderByDisplayDateForConversation:(GLPConversation *)conversation
{
    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from messages where conversation_key=%d order by displayDate ASC", conversation.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    while ([resultSet next]) {
        [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet]];
    }
    
    return result;
}

+ (NSArray *)insertNewMessages:(NSArray *)newMessages andFindAllForConversation:(GLPConversation *)conversation
{
    [[DatabaseManager sharedInstance].database beginTransaction];
    
    for(GLPMessage *message in newMessages) {
        [GLPMessageDao save:message];
    }
    
    NSArray *result = [GLPMessageDao findLastMessagesForConversation:conversation];
    
    [[DatabaseManager sharedInstance].database commit];
    
    return result;

}

//+ (NSArray *)findAllOrderByDateForConversation:(GLPConversation *)conversation afterInsertingNewMessages:(NSArray *)newMessages
//{
//    [[DatabaseManager sharedInstance].database beginTransaction];
//    
//    // remove 
//    
//    for(GLPMessage *message in newMessages) {
//        [GLPMessageDao save:message];
//    }
//    
//    NSArray *result = [GLPMessageDao findAllOrderByDateForConversation:conversation];
//    
//    [[DatabaseManager sharedInstance].database commit];
//    
//    return result;
//}

+ (GLPMessage *)findByRemoteKey:(NSInteger)remoteKey
{
    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from messages where remoteKey=%d", remoteKey];
    
    if(![resultSet next]) {
        return nil;
    }
    
    return [GLPMessageDaoParser createFromResultSet:resultSet];
}

+ (GLPMessage *)findLastRemoteAndSeenForConversation:(GLPConversation *)conversation
{
    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from messages where remote_key!=0 AND seen=1 AND conversation_key=%d order by remote_key DESC", conversation.remoteKey];
    
    if(![resultSet next]) {
        return nil;
    }
    
    return [GLPMessageDaoParser createFromResultSet:resultSet];
}

+ (void)save:(GLPMessage *)entity
{
    int date = [entity.date timeIntervalSince1970];
    
    [[DatabaseManager sharedInstance].database executeUpdateWithFormat:@"insert into messages (remoteKey, content, date, sendStatus, displayOrder, author_key, conversation_key) values(%d, %@, %d, %d, (SELECT IFNULL(MAX(key), 0) + 1 FROM messages), %d, %d)",
            entity.remoteKey,
            entity.content,
            date,
            entity.sendStatus,
            entity.author.remoteKey,
            entity.conversation.remoteKey];
    
    entity.key = [[DatabaseManager sharedInstance].database lastInsertRowId];
}

+ (void)saveOld:(GLPMessage *)entity
{
    int date = [entity.date timeIntervalSince1970];
    [[DatabaseManager sharedInstance].database executeUpdateWithFormat:@"insert into messages (remoteKey, content, date, sendStatus, displayOrder, author_key, conversation_key) values(%d, %@, %d, %d, %d, %d)",
     entity.remoteKey,
     entity.content,
     date,
     entity.sendStatus,
     -1,
     entity.author.remoteKey,
     entity.conversation.remoteKey];

    entity.key = [[DatabaseManager sharedInstance].database lastInsertRowId];
}

+ (void)update:(GLPMessage *)entity
{
    NSAssert(entity.key != 0, @"Cannot save entity without key");
    
    int date = [entity.date timeIntervalSince1970];
    
    [[DatabaseManager sharedInstance].database executeUpdateWithFormat:@"update messages set remoteKey=%d, content=%@, date=%d, sendStatus=%d, seen=%d, author_key=%d, conversation_key=%d where key=%d",
     entity.remoteKey,
     entity.content,
     date,
     entity.sendStatus,
     entity.seen,
     entity.author.remoteKey,
     entity.conversation.remoteKey,
     entity.key];
}

+ (void)saveNewMessageWithPossiblyNewConversation:(GLPMessage *)message
{
    [[DatabaseManager sharedInstance].database beginTransaction];

    GLPConversation *existingConversation = [GLPConversationDao findByRemoteKey:message.conversation.remoteKey];
    if(existingConversation) {
        message.conversation = existingConversation;
        NSLog(@"existing conversation %d", existingConversation.remoteKey);
    } else {
        [GLPConversationDao save:message.conversation];
        //TODO: check works properly
    }
    
    [GLPMessageDao save:message];
    [[DatabaseManager sharedInstance].database commit];
}

@end
