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
#import "ConversationManager.h"

@implementation GLPMessageDao

+ (NSArray *)findLastMessagesForConversation:(GLPConversation *)conversation db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from messages where conversation_key=%d order by isOld, key DESC limit %d", conversation.remoteKey, NumberMaxOfMessagesLoaded];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet db:db]];
    }
    
    return [[result reverseObjectEnumerator] allObjects]; // reverse order so that the most recent message is at the end
}

+ (NSArray *)findPreviousMessagesBefore:(GLPMessage *)message db:(FMDatabase *)db
{
    FMResultSet *resultSet;
    if(message.isOld) {
        resultSet = [db executeQueryWithFormat:@"select * from messages where conversation_key=%d and remoteKey < %d and isOld = 1 order by remoteKey desc limit %d", message.conversation.remoteKey, message.remoteKey, NumberMaxOfMessagesLoaded];
    } else {
        resultSet = [db executeQueryWithFormat:@"select * from messages where conversation_key=%d and case when isOld = 0 then key < %d else remoteKey < %d end order by isOld, case when isOld = 0 then key else remoteKey end desc limit %d;", message.conversation.remoteKey, message.key, message.remoteKey, NumberMaxOfMessagesLoaded];
    }

    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet db:db]];
    }
    
    return [[result reverseObjectEnumerator] allObjects]; // reverse order so that the most recent message is at the end
}

//todo: put somewhere else
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

//+ (NSArray *)insertNewMessages:(NSArray *)newMessages andFindAllForConversation:(GLPConversation *)conversation
//{
//    __block NSArray *result;
//    
//    [[DatabaseManager sharedInstance].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        for(GLPMessage *message in newMessages) {
//            [GLPMessageDao save:message db:db];
//        }
//        
//        result = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
//
//    }];
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

//todo: to remove or put somewhere else
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

+ (void)save:(GLPMessage *)entity
{
    [[DatabaseManager sharedInstance].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPMessageDao save:entity db:db];
    }];
}

+ (void)save:(GLPMessage *)entity db:(FMDatabase *)db
{
    int date = [entity.date timeIntervalSince1970];
    
    //todo: need to refactor this
    if(entity.conversation == nil)
    {
        [db executeUpdateWithFormat:@"insert into messages (remoteKey, content, date, sendStatus, author_key, conversation_key) values(%d, %@, %d, %d, %d, %d)",
         entity.remoteKey,
         entity.content,
         date,
         entity.sendStatus,
         entity.author.remoteKey,
         entity.liveConversation.remoteKey];
    }
    else
    {
        [db executeUpdateWithFormat:@"insert into messages (remoteKey, content, date, sendStatus, isOld, author_key, conversation_key) values(%d, %@, %d, %d, %d, %d, %d)",
         entity.remoteKey,
         entity.content,
         date,
         entity.sendStatus,
         entity.isOld,
         entity.author.remoteKey,
         entity.conversation.remoteKey];
    }
    

    
    
    entity.key = [db lastInsertRowId];
    
    //todo: need to remove this
    //Fetch user's id.
    GLPUser *user = [GLPUserDao findByRemoteKey:entity.author.remoteKey db:db];
    
    //Insert into message participants the message and user (local) id.
    if([db executeUpdateWithFormat:@"insert into messages_participants (user_key, message_key) values(%d, %d)",user.key ,entity.key])
    {
        //NSLog(@"Executed.");
    }
    else
    {
        //NSLog(@"Error inserting message per user.");
    }
}

+ (void)update:(GLPMessage *)entity db:(FMDatabase *)db
{
    NSAssert(entity.remoteKey != 0, @"Cannot update entity without key");
    
    int date = [entity.date timeIntervalSince1970];
    
    //todo: refactor this
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

@end
