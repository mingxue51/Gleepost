//
//  GLPLiveConversationParticipantsDao.m
//  Gleepost
//
//  Created by Σιλουανός on 8/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversationParticipantsDao.h"
#import "FMResultSet.h"
#import "GLPUserDao.h"
#import "GLPLiveUserDao.h"

@implementation GLPLiveConversationParticipantsDao

+ (NSInteger)findByParticipantKey:(NSInteger)participantLocalKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from live_conversations_participants where live_user_key=%d limit 1", participantLocalKey];
    
    int convId = -1;
    
    if([resultSet next]) {
        
        convId = [resultSet intForColumn:@"live_conversation_key"];
        
    }
    
    return convId;
}

+(NSInteger)findByConversationKey:(NSInteger)conversationKey db:(FMDatabase*)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from live_conversations_participants where live_conversation_key=%d limit 1", conversationKey];
    
    int partId = -1;
    
    if([resultSet next])
    {
        partId = [resultSet intForColumn:@"live_user_key"];
    }
    
    
    return partId;
}

+(NSArray*)participants:(NSInteger)conversationKey db:(FMDatabase*)db
{
    /**
     
     FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from messages where conversation_key=%d and displayOrder < %d order by displayOrder DESC limit 20", message.conversation.remoteKey, message.displayOrder];
     
     NSMutableArray *result = [NSMutableArray array];
     
     while ([resultSet next]) {
     [result addObject:[GLPMessageDaoParser createFromResultSet:resultSet db:db]];
     }
     
     return [[result reverseObjectEnumerator] allObjects];
     
     */
    /**
     sqlite> SELECT Name, Day FROM Customers AS C JOIN Reservations
     ...> AS R ON C.CustomerId=R.CustomerId;
     */
    
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from live_conversations_participants where live_conversation_key=%d",conversationKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next])
    {
        NSLog(@"Live User key: %d, Conversation key: %d", [resultSet intForColumn:@"live_user_key"], [resultSet intForColumn:@"live_conversation_key"]);
        int keyUser = [resultSet intForColumn:@"live_user_key"];
        
        //[result addObject:[NSNumber numberWithInt:[resultSet intForColumn:@"user_key"]]];
        
        [result addObject:[GLPLiveUserDao findByKey:keyUser db:db]];
    }
    
    return result;
}

+ (void)deleteAll:(FMDatabase *)db
{
    [db executeUpdate:@"delete from live_conversations_participants"];
}
@end
