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

@implementation GLPConversationDao

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

+ (NSArray *)findConversationsOrderByDateInDb:(FMDatabase *)db;
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations order by lastUpdate DESC"];
    
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
    
    DDLogDebug(@"Reads from database %@", result);
    
    return result;
}

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

    
    [db executeUpdateWithFormat:@"insert into conversations (remoteKey, lastMessage, lastUpdate, title, participants_keys, unread, isGroup, isLive) values(%d, %@, %d, %@, %@, %d, %d, %d)",
     entity.remoteKey,
     entity.lastMessage,
     date,
     entity.title,
     participants,
     entity.hasUnreadMessages,
     entity.isGroup,
     entity.isLive];
    
    entity.key = [db lastInsertRowId];
    
    for(GLPConversationRead *conversationRead in entity.reads)
    {
        [db executeUpdateWithFormat:@"insert into conversations_reads (conversation_remote_key, participant_remote_key, message_read_remote_key) values(%d, %d, %d)",
         entity.remoteKey,
         conversationRead.participant.remoteKey,
         conversationRead.messageRemoteKey];
    }
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
    
    int date = [entity.lastUpdate timeIntervalSince1970];
    
    //    NSArray *keys = [entity.participants valueForKeyPath:@"key"];
    NSString *participants = [keys componentsJoinedByString:@";"];
    
    
    GLPConversation *conv = [GLPConversationDao findByRemoteKey:entity.remoteKey db:db];

    if(conv == nil)
    {
        //Conversation doesn't exist, add conversation.
        
        [db executeUpdateWithFormat:@"insert into conversations (remoteKey, lastMessage, lastUpdate, title, participants_keys, unread, isGroup, isLive) values(%d, %@, %d, %@, %@, %d, %d, %d)",
         entity.remoteKey,
         entity.lastMessage,
         date,
         entity.title,
         participants,
         entity.hasUnreadMessages,
         entity.isGroup,
         entity.isLive];
        
        entity.key = [db lastInsertRowId];
        
        for(GLPConversationRead *conversationRead in entity.reads)
        {
            [db executeUpdateWithFormat:@"insert into conversations_reads (conversation_remote_key, participant_remote_key, message_read_remote_key) values(%d, %d, %d)",
             entity.remoteKey,
             conversationRead.participant.remoteKey,
             conversationRead.messageRemoteKey];
        }
    }
    else
    {
        //Update conversation.
        [GLPConversationDao update:entity db:db];
    }
}


+ (void)update:(GLPConversation *)entity db:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Cannot update entity without key");
    
    int date = [entity.lastUpdate timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"update conversations set remoteKey=%d, lastMessage=%@, lastUpdate=%d, title=%@, unread=%d where remoteKey=%d",
     entity.remoteKey,
     entity.lastMessage,
     date,
     entity.title,
     entity.hasUnreadMessages,
     entity.remoteKey];
    
    [GLPConversationDao updateReads:entity db:db];
}

+ (void)updateConversationLastUpdateAndLastMessage:(GLPConversation *)entity db:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Cannot update entity without key");
    
    [db executeUpdateWithFormat:@"update conversations set lastMessage=%@, lastUpdate=%d where key=%d",
     entity.lastMessage,
     entity.lastUpdate,
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


+ (void)deleteAllNormalConversationsInDb:(FMDatabase *)db
{
    [db executeUpdate:@"delete from conversations where isLive=0"];
    [db executeUpdate:@"delete from conversations_reads"];
}


@end
