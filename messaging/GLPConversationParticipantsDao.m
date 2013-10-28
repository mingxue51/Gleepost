//
//  GLPConversationParticipantsDao.m
//  Gleepost
//
//  Created by Σιλουανός on 25/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPConversationParticipantsDao.h"
#import "FMResultSet.h"

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

+ (void)deleteAll:(FMDatabase *)db
{
    [db executeUpdate:@"delete from conversations_participants"];
}

@end
