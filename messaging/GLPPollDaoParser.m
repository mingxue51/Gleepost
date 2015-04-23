//
//  GLPPollDaoParser.m
//  Gleepost
//
//  Created by Silouanos on 23/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPPollDaoParser.h"
#import "GLPPoll.h"
#import "FMDatabase.h"

@implementation GLPPollDaoParser

+ (GLPPoll *)parseResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPPoll *entity = [[GLPPoll alloc] initWithKey:[resultSet intForColumn:@"key"]];
    entity.expirationDate = [resultSet dateForColumn:@"expiration"];
    entity.usersVote = [resultSet stringForColumn:@"users_vote"];
    
    return entity;
}

+ (GLPPoll *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    return [GLPPollDaoParser parseResultSet:resultSet inDb:db];
}

+ (GLPPoll *)updateWithOptionsVotesFromResultSet:(FMResultSet *)resultSet withPoll:(GLPPoll *)poll inDb:(FMDatabase *)db
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    NSMutableDictionary *votes = [[NSMutableDictionary alloc] init];
    
    while ([resultSet next])
    {
        NSString *option = [resultSet stringForColumn:@"option"];
        NSInteger vote = [resultSet intForColumn:@"votes"];
        
        [options addObject:option];
        [votes setObject:@(vote) forKey:option];
        
    }
    
    poll.options = options;
    [poll setAndCalculateVotes: votes];
    
    return poll;
}

@end
