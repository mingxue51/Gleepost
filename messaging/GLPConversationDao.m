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

@implementation GLPConversationDao

+ (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations where remoteKey=%d limit 1", remoteKey];
    
    if(![resultSet next]) {
        return nil;
    }
    
    return [GLPConversationDaoParser createFromResultSet:resultSet inDb:db];
}

+ (NSArray *)findConversationsOrderByDateFilterByLive:(BOOL)liveConversations inDb:(FMDatabase *)db;
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations where isLive=%d order by lastUpdate DESC", liveConversations];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPConversationDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
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
}

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
}

+ (void)updateConversationUnreadStatus:(GLPConversation *)entity db:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Cannot update entity without key");
    
    [db executeUpdateWithFormat:@"update conversations set unread=%d where key=%d",
     entity.hasUnreadMessages,
     entity.key];
}

+ (void)deleteAllNormalConversationsInDb:(FMDatabase *)db
{
    [db executeUpdate:@"delete from conversations where isLive=0"];
}


@end
