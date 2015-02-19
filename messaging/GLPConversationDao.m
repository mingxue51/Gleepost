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
#import "GLPUserDao.h"
#import "SessionManager.h"
#import "FMDatabaseAdditions.h"
#import "GLPConversationRead.h"
#import "GLPReadReceipt.h"

@implementation GLPConversationDao

#pragma mark - Find methods

+ (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations where remoteKey=%d limit 1", remoteKey];
    
    if(![resultSet next]) {
        return nil;
    }
    
    return [GLPConversationDaoParser createFromResultSet:resultSet inDb:db];
}

+ (GLPConversation *)findByParticipantKey:(int)key db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations where participants_keys=%d limit 1", key];
    
    if(![resultSet next]) {
        return nil;
    }
    
    return [GLPConversationDaoParser createFromResultSet:resultSet inDb:db];
}

+ (NSArray *)findMessengerConversationsOrderByDateInDb:(FMDatabase *)db;
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations where group_remote_key = 0 order by lastUpdate DESC"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPConversationDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (NSArray *)findGroupsConversationsOrderByDateInDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations where group_remote_key != 0 order by lastUpdate DESC"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPConversationDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (NSArray *)findReadsWithConversation:(GLPConversation *)entity andDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations_reads where conversation_remote_key=%d", entity.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        
        NSInteger participantRemoteKey = [resultSet intForColumn:@"participant_remote_key"];
        NSInteger messageRemoteKey = [resultSet intForColumn:@"message_read_remote_key"];
        
        GLPUser *participant = [GLPUserDao findByRemoteKey:participantRemoteKey db:db];
        
        [result addObject:[[GLPConversationRead alloc] initWithParticipant:participant andMessageRemoteKey:messageRemoteKey]];
    }
        
    return result;
}

+ (BOOL)doesReadReceipt:(GLPReadReceipt *)readReceipt existsInDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations_reads where conversation_remote_key=%d AND participant_remote_key=%d limit 1", [readReceipt getConversationRemoteKey], [readReceipt getLastUser].remoteKey];
    
    if(![resultSet next]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Save methods

+ (void)save:(GLPConversation *)entity db:(FMDatabase *)db
{
    // save the users that does not exist
    // first because we want the key to exists
    NSMutableArray *keys = [NSMutableArray array];
    for(GLPUser *user in entity.participants) {
        int key = user.key;
        
        if(key == 0) {
            GLPUser *existingUser = [GLPUserDao findByRemoteKey:user.remoteKey db:db];
            
            if(existingUser) {
                key = existingUser.key;
            } else {
                [GLPUserDao save:user inDb:db];
                key = user.key;
            }
        }
        
        [keys addObject:[NSNumber numberWithInt:key]];
    }
    
    int date = [entity.lastUpdate timeIntervalSince1970];
    
//    NSArray *keys = [entity.participants valueForKeyPath:@"key"];
    NSString *participants = [keys componentsJoinedByString:@";"];

    
    [db executeUpdateWithFormat:@"insert into conversations (remoteKey, lastMessage, lastUpdate, title, participants_keys, unread, isGroup, isLive, group_remote_key) values(%d, %@, %d, %@, %@, %d, %d, %d, %d)",
     entity.remoteKey,
     entity.lastMessage,
     date,
     entity.title,
     participants,
     entity.hasUnreadMessages,
     entity.isGroup,
     entity.isLive,
     entity.groupRemoteKey];
    
    entity.key = [db lastInsertRowId];
    
    [GLPConversationDao saveConversationReads:entity withDb:db];
}

+ (void)saveConversationReads:(GLPConversation *)conversation withDb:(FMDatabase *)db
{
    for(GLPConversationRead *conversationRead in conversation.reads)
    {
        [db executeUpdateWithFormat:@"insert into conversations_reads (conversation_remote_key, participant_remote_key, message_read_remote_key) values(%d, %d, %d)",
         conversation.remoteKey,
         conversationRead.participant.remoteKey,
         conversationRead.messageRemoteKey];
    }
}

+ (void)saveRead:(GLPReadReceipt *)readReceipt db:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"insert into conversations_reads (conversation_remote_key, participant_remote_key, message_read_remote_key) values(%d, %d, %d)",
     [readReceipt getConversationRemoteKey],
     [readReceipt  getLastUser].remoteKey,
     [readReceipt getMesssageRemoteKey]];
}


//Added.

/**
 By implementing this method we are avoiding retrying save the same conversation from the web socket
 in case we are creating explicictly conversation.
 */
+ (void)saveIfNotExist:(GLPConversation *)entity db:(FMDatabase *)db
{
    // save the users that does not exist
    // first because we want the key to exists
    NSMutableArray *keys = [NSMutableArray array];
    for(GLPUser *user in entity.participants) {
        int key = user.key;
        
        if(key == 0) {
            GLPUser *existingUser = [GLPUserDao findByRemoteKey:user.remoteKey db:db];
            
            if(existingUser) {
                key = existingUser.key;
            } else {
                [GLPUserDao save:user inDb:db];
                key = user.key;
            }
        }
        
        [keys addObject:[NSNumber numberWithInt:key]];
    }
    
    GLPConversation *conv = [GLPConversationDao findByRemoteKey:entity.remoteKey db:db];

    if(conv == nil)
    {
        //Conversation doesn't exist, add conversation.
        [GLPConversationDao save:entity db:db];
    }
    else
    {
        entity.key = conv.key;

        //Update conversation.
        [GLPConversationDao update:entity db:db];
    }
}

+ (void)saveReadReceiptIfNotExist:(GLPReadReceipt *)readReceipt db:(FMDatabase *)db
{
    if([GLPConversationDao doesReadReceipt:readReceipt existsInDb:db])
    {
        [GLPConversationDao updateRead:readReceipt db:db];
    }
    else
    {
        [GLPConversationDao saveRead:readReceipt db:db];
    }
}

#pragma mark - Update methods

+ (void)update:(GLPConversation *)entity db:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Cannot update entity without key");
    
    int date = [entity.lastUpdate timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"update conversations set remoteKey=%d, lastMessage=%@, lastUpdate=%d, title=%@, unread=%d where key=%d",
     entity.remoteKey,
     entity.lastMessage,
     date,
     entity.title,
     entity.hasUnreadMessages,
     entity.key];
    
    [GLPConversationDao updateReads:entity db:db];
}

+ (void)updateConversationLastUpdateAndLastMessage:(GLPConversation *)entity db:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Cannot update entity without key");
    
    int lastUpdate = [entity.lastUpdate timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"update conversations set lastMessage=%@, lastUpdate=%d where key=%d",
     entity.lastMessage,
     lastUpdate,
     entity.key];
}

+ (void)updateConversationUnreadStatus:(GLPConversation *)entity db:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Cannot update entity without key");
    
    [db executeUpdateWithFormat:@"update conversations set unread=%d where key=%d",
     entity.hasUnreadMessages,
     entity.key];
}


+ (void)updateReads:(GLPConversation *)entity db:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Cannot update entity without key");
    
    for(GLPConversationRead *read in entity.reads)
    {
        [db executeUpdateWithFormat:@"update conversations_reads set message_read_remote_key=%d where conversation_remote_key=%d AND participant_remote_key=%d", read.messageRemoteKey, entity.remoteKey, read.participant.remoteKey];
    }
}

+ (void)updateRead:(GLPReadReceipt *)readReceipt db:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"update conversations_reads set message_read_remote_key=%d where conversation_remote_key=%d AND participant_remote_key=%d", [readReceipt getMesssageRemoteKey], [readReceipt getConversationRemoteKey], [readReceipt getLastUser].remoteKey];
}

#pragma mark - Delete methods

+ (void)deleteConversationWithRemoteKey:(NSInteger)conversationRemoteKey db:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"delete from conversations_reads where conversation_remote_key=%d", conversationRemoteKey];
    
    [db executeUpdateWithFormat:@"delete from conversations where remoteKey=%d", conversationRemoteKey];
    
}


+ (void)deleteAllNormalConversationsInDb:(FMDatabase *)db
{
    [db executeUpdate:@"delete from conversations_reads"];
    [db executeUpdate:@"delete from conversations where isLive=0"];
    
    //Delete the conversations' entry from sequence table in order to reset the autoincrement attribute.
    [db executeUpdateWithFormat:@"delete from sqlite_sequence where name=%@", @"conversations"];
}


@end
