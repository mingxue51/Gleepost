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
#import "GLPUserDaoParser.h"
#import "GLPUserDao.h"

@implementation GLPMessageDao

+ (NSArray *)findLastMessagesForConversation:(GLPConversation *)conversation
{
    __block NSArray *result;
    
    [[DatabaseManager sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        result = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
    }];
    
    return result;
}

+ (NSArray *)findLastMessagesForConversation:(GLPConversation *)conversation db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from messages where conversation_key=%d order by displayOrder DESC limit 20", conversation.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet db:db]];
    }
    
    return [[result reverseObjectEnumerator] allObjects];
}


+ (NSArray *)findLastMessagesForLiveConversation:(GLPLiveConversation *)conversation db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from messages where conversation_key=%d order by displayOrder DESC limit 20", conversation.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet db:db]];
    }
    
    return [[result reverseObjectEnumerator] allObjects];
}

//+ (NSArray *)findAllOrderByDisplayDateForConversation:(GLPConversation *)conversation
//{
//    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from messages where conversation_key=%d order by displayDate ASC", conversation.remoteKey];
//    
//    NSMutableArray *result = [NSMutableArray array];
//    while ([resultSet next]) {
//        [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet]];
//    }
//    
//    return result;
//}

+ (NSArray *)insertNewMessages:(NSArray *)newMessages andFindAllForConversation:(GLPConversation *)conversation
{
    __block NSArray *result;
    
    [[DatabaseManager sharedInstance].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for(GLPMessage *message in newMessages) {
            [GLPMessageDao save:message db:db];
        }
        
        result = [GLPMessageDao findLastMessagesForConversation:conversation db:db];

    }];
    
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
    __block GLPMessage *message = nil;
    
    [DatabaseManager run:^(FMDatabase *db) {
        message = [GLPMessageDao findByRemoteKey:remoteKey];
    }];
    
    return message;
}

+ (GLPMessage *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from messages where remoteKey=%d", remoteKey];
    
    if(![resultSet next]) {
        return nil;
    }
    
    return [GLPMessageDaoParser createFromResultSet:resultSet db:db];
}

/**
 Added.
 */

+(GLPUser *)findUserByMessageKey:(NSInteger)messageKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from messages_participants where message_key=%d", messageKey];
    
    if(![resultSet next]) {
        return nil;
    }
    
    int userId = [resultSet intForColumn:@"user_key"];
    
    //Get user using id.
    GLPUser* urs = [GLPUserDao findByKey:userId db:db];
    
//    GLPUser* urs = [GLPUserDaoParser createUserFromResultSet:resultSet];
    
    return urs;
}

//+ (GLPMessage *)findLastRemoteAndSeenForConversation:(GLPConversation *)conversation
//{
//    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from messages where remote_key!=0 AND seen=1 AND conversation_key=%d order by remote_key DESC", conversation.remoteKey];
//    
//    if(![resultSet next]) {
//        return nil;
//    }
//    
//    return [GLPMessageDaoParser createFromResultSet:resultSet];
//}

+ (void)save:(GLPMessage *)entity
{
    [[DatabaseManager sharedInstance].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPMessageDao save:entity db:db];
    }];
}

+ (void)save:(GLPMessage *)entity db:(FMDatabase *)db
{
    int date = [entity.date timeIntervalSince1970];
    
    if(entity.conversation == nil)
    {
        [db executeUpdateWithFormat:@"insert into messages (remoteKey, content, date, sendStatus, displayOrder, author_key, conversation_key) values(%d, %@, %d, %d, (SELECT IFNULL(MAX(key), 0) + 1 FROM messages), %d, %d)",
         entity.remoteKey,
         entity.content,
         date,
         entity.sendStatus,
         entity.author.remoteKey,
         entity.liveConversation.remoteKey];
    }
    else
    {
        [db executeUpdateWithFormat:@"insert into messages (remoteKey, content, date, sendStatus, displayOrder, author_key, conversation_key) values(%d, %@, %d, %d, (SELECT IFNULL(MAX(key), 0) + 1 FROM messages), %d, %d)",
         entity.remoteKey,
         entity.content,
         date,
         entity.sendStatus,
         entity.author.remoteKey,
         entity.conversation.remoteKey];
    }
    

    
    
    entity.key = [db lastInsertRowId];
    
    //Fetch user's id.
    GLPUser *user = [GLPUserDao findByRemoteKey:entity.author.remoteKey db:db];
    
    //Insert into message participants the message and user (local) id.
    if([db executeUpdateWithFormat:@"insert into messages_participants (user_key, message_key) values(%d, %d)",user.key ,entity.key])
    {
        NSLog(@"Executed.");
    }
    else
    {
        NSLog(@"Error inserting message per user.");
    }
}

//+ (void)saveOld:(GLPMessage *)entity
//{
//    int date = [entity.date timeIntervalSince1970];
//    [[DatabaseManager sharedInstance].database executeUpdateWithFormat:@"insert into messages (remoteKey, content, date, sendStatus, displayOrder, author_key, conversation_key) values(%d, %@, %d, %d, %d, %d)",
//     entity.remoteKey,
//     entity.content,
//     date,
//     entity.sendStatus,
//     -1,
//     entity.author.remoteKey,
//     entity.conversation.remoteKey];
//
//    entity.key = [[DatabaseManager sharedInstance].database lastInsertRowId];
//}

+ (void)update:(GLPMessage *)entity db:(FMDatabase *)db
{
    NSAssert(entity.remoteKey != 0, @"Cannot update entity without key");
    
    int date = [entity.date timeIntervalSince1970];
    
    if(entity.conversation == nil)
    {
        [db executeUpdateWithFormat:@"update messages set remoteKey=%d, content=%@, date=%d, sendStatus=%d, seen=%d, author_key=%d, conversation_key=%d where key=%d",
         entity.remoteKey,
         entity.content,
         date,
         entity.sendStatus,
         entity.seen,
         entity.author.remoteKey,
         entity.liveConversation.remoteKey,
         entity.key];
    }
    else
    {
        [db executeUpdateWithFormat:@"update messages set remoteKey=%d, content=%@, date=%d, sendStatus=%d, seen=%d, author_key=%d, conversation_key=%d where key=%d",
         entity.remoteKey,
         entity.content,
         date,
         entity.sendStatus,
         entity.seen,
         entity.author.remoteKey,
         entity.conversation.remoteKey,
         entity.key];
    }
    

}



//+ (void)saveNewMessageWithPossiblyNewConversation:(GLPMessage *)message db:(FMDatabase *)db
//{
//
//    GLPConversation *existingConversation = [GLPConversationDao findByRemoteKey:message.conversation.remoteKey db:db];
//    
//    if(existingConversation) {
//        message.conversation = existingConversation;
//        NSLog(@"existing conversation %d", existingConversation.remoteKey);
//    } else {
//        [GLPConversationDao save:message.conversation db:db];
//        //TODO: check works properly
//    }
//    
//    [GLPMessageDao save:message];
//    [[DatabaseManager sharedInstance].database commit];
//}

@end
