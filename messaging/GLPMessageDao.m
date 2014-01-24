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

+ (GLPMessage *)findLastRemoteMessageForConversation:(GLPConversation *)conversation db:(FMDatabase *)db
{
    
}

+ (NSArray *)findLastMessagesForConversation:(GLPConversation *)conversation db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from messages where conversation_key=%d order by isOld, key DESC limit %d", conversation.remoteKey, NumberMaxOfMessagesLoaded];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        GLPMessage *m = [GLPMessageDaoParser createFromResultSet:resultSet db:db];
        m.conversation = conversation;
        [result addObject:m];
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

+ (void)save:(GLPMessage *)entity db:(FMDatabase *)db
{
    NSAssert(entity.conversation, @"Conversation can't be nil");
    NSAssert(entity.conversation.remoteKey != 0, @"Conversation can't have nil remoteKey");
    
    NSString *sql = @"insert into messages (remoteKey, content, date, sendStatus, seen, isOld, author_key, conversation_key) values(:remoteKey, :content, :date, :sendStatus, :seen, :isOld, :author_key, :conversation_key)";
    
    int date = [entity.date timeIntervalSince1970];
    id remoteKey = (entity.remoteKey == 0) ? [NSNull null] : [NSNumber numberWithInt:entity.remoteKey];
    
    NSDictionary *params = @{
                             @"remoteKey": remoteKey,
                             @"content": entity.content,
                             @"date": [NSNumber numberWithInt:date],
                             @"sendStatus": [NSNumber numberWithInt:entity.sendStatus],
                             @"seen": [NSNumber numberWithBool:entity.seen],
                             @"isOld": [NSNumber numberWithBool:entity.isOld],
                             @"author_key": [NSNumber numberWithInt:entity.author.remoteKey],
                             @"conversation_key": [NSNumber numberWithInt:entity.conversation.remoteKey]
                             };
    
    [db executeUpdate:sql withParameterDictionary:params];
    entity.key = [db lastInsertRowId];
}

+ (void)updateAfterSending:(GLPMessage *)entity db:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Cannot update entity without key");
    
    NSString *sql = @"update messages set remoteKey=:remoteKey, sendStatus=:sendStatus where key=:key";
    
    id remoteKey = (entity.remoteKey == 0) ? [NSNull null] : [NSNumber numberWithInt:entity.remoteKey];
    
    NSDictionary *params = @{
                             @"remoteKey": remoteKey,
                             @"sendStatus": [NSNumber numberWithInt:entity.sendStatus],
                             };
    
    [db executeUpdate:sql withParameterDictionary:params];
}
@end
