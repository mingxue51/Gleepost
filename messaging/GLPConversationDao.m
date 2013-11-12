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
#import "GLPConversationParticipantsDao.h"
#import "SessionManager.h"

@implementation GLPConversationDao

+ (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPConversation *conversation;
    
    [DatabaseManager run:^(FMDatabase *db) {
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
    
    [db executeUpdateWithFormat:@"insert into conversations(remoteKey, lastMessage, lastUpdate, title, unread, isGroup) values(%d, %@, %d, %@, %d, %d)",
     entity.remoteKey,
     entity.lastMessage,
     date,
     entity.title,
     entity.hasUnreadMessages,
     entity.isGroup];
    
    entity.key = [db lastInsertRowId];
    
    GLPUser *opponentUser = nil;
    
    for(GLPUser *user in entity.participants)
    {
        if(user.remoteKey != [[SessionManager sharedInstance]user].remoteKey)
        {
            opponentUser = user;
        }
    }
    
    
    [GLPConversationDao insertConversationParticipantIfNotExist:entity.key withUserId: [GLPUserDao saveIfNotExist:opponentUser db:db] andDb:db];

    
    
    //TODO: Added.
    //Insert a participant if not exist.
    for(GLPUser *user in entity.participants)
    {
        NSLog(@"Participant id: %d With conversation id: %d", user.remoteKey, entity.key);
       
    }
    
    //Insert participants and conversation id in conversation participants table if are not exist.
    
    
    
    //TODO: Do this after inserting the users into database.
    //Save each conversation and users.
    for(GLPUser *user in entity.participants)
    {
        NSLog(@"Participant id: %d With conversation id: %d", user.remoteKey, entity.key);
    }
    
}

+ (void)insertConversationParticipantIfNotExist: (int)conversationId withUserId: (int)userId andDb:(FMDatabase* )db
{
    //If participant is not exist, add the conversation, participant id pairs.
    int convId = [GLPConversationParticipantsDao findByParticipantKey:userId db:db];
    
    if(convId == -1)
    {
        [db executeUpdateWithFormat:@"insert into conversations_participants(user_key, conversation_key) values(%d, %d)", userId, conversationId];
    }
    
}

+ (void)update:(GLPConversation *)entity db:(FMDatabase *)db
{
    //TODO: Changed.
    NSAssert(entity.remoteKey != 0, @"Cannot update entity without key");
    
    int date = [entity.lastUpdate timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"update conversations set remoteKey=%d, lastMessage=%@, lastUpdate=%d, title=%@, unread=%d where key=%d",
     entity.remoteKey,
     entity.lastMessage,
     date,
     entity.title,
     entity.hasUnreadMessages,
     entity.key];
}

+ (void)updateUnread:(GLPConversation *)entity db:(FMDatabase *)db
{
    NSAssert(entity.remoteKey != 0, @"Cannot update entity without key");
    
    [db executeUpdateWithFormat:@"update conversations set unread=%d where key=%d",
     entity.hasUnreadMessages,
     entity.key];
}

+ (void)deleteAll:(FMDatabase *)db
{
    [db executeUpdate:@"delete from conversations"];
}


@end
