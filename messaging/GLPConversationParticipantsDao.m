//
//  GLPConversationParticipantsDao.m
//  Gleepost
//
//  Created by Σιλουανός on 25/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPConversationParticipantsDao.h"
#import "FMResultSet.h"
#import "GLPUserDao.h"
#import "DatabaseManager.h"

@implementation GLPConversationParticipantsDao



+ (NSInteger)findByParticipantKey:(NSInteger)participantLocalKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations_participants where user_key=%d limit 1", participantLocalKey];
    
    int convId = -1;
    
    if([resultSet next]) {
        
        convId = [resultSet intForColumn:@"conversation_key"];

    }
    
    return convId;
}

+(NSInteger)findByConversationKey:(NSInteger)conversationKey db:(FMDatabase*)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations_participants where conversation_key=%d limit 1", conversationKey];
    
    int partId = -1;
    
    if([resultSet next])
    {
        partId = [resultSet intForColumn:@"user_key"];
    }
    
    
    return partId;
}

+(NSArray*)participants:(NSInteger)conversationKey
{
    
    __block NSArray* participants = [[NSArray alloc] init];
    
    [DatabaseManager run:^(FMDatabase *db) {
        
        participants = [GLPConversationParticipantsDao participants:conversationKey db:db];
        
    }];
    
    return participants;
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
    
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from conversations_participants where conversation_key=%d",conversationKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next])
    {
//        NSLog(@"User key: %d, Conversation key: %d", [resultSet intForColumn:@"user_key"], [resultSet intForColumn:@"conversation_key"]);
        int keyUser = [resultSet intForColumn:@"user_key"];
        
        int convUser = [resultSet intForColumn:@"conversation_key"];
        
        //[result addObject:[NSNumber numberWithInt:[resultSet intForColumn:@"user_key"]]];
        
        [result addObject:[GLPUserDao findByKey:keyUser db:db]];
    }
    
    return result;
}

+ (void)deleteAll:(FMDatabase *)db
{
    [db executeUpdate:@"delete from conversations_participants"];
}

@end
