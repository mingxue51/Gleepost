//
//  GLPPollDao.m
//  Gleepost
//
//  Created by Silouanos on 23/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPPollDao.h"
#import "DatabaseManager.h"
#import "GLPPollDaoParser.h"
#import "GLPPoll.h"

@implementation GLPPollDao

+ (GLPPoll *)findPollWithPostRemoteKey:(NSInteger)postRemoteKey
{
    __block GLPPoll *poll = nil;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        poll = [self findPollWithPostRemoteKey:postRemoteKey db:db];
    }];
    
    return poll;
}

+ (NSInteger)findPollKeyByPostRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from polls where postRemoteKey=%d limit 1", remoteKey];
    
    NSInteger pollKey = -1;
    
    if([resultSet next]) {
        GLPPoll *p = [GLPPollDaoParser createFromResultSet:resultSet inDb:db];
        pollKey = p.key;
    }
    
    return pollKey;
}

+ (GLPPoll *)findPollWithPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db
{
    GLPPoll *poll = nil;
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from polls where postRemoteKey=%d limit 1", postRemoteKey];

    if([resultSet next]) {
        poll = [GLPPollDaoParser createFromResultSet:resultSet inDb:db];
    }
    
    return [GLPPollDao findAllOptionsDataForPoll:poll db:db];
}

+ (GLPPoll *)findAllOptionsDataForPoll:(GLPPoll *)poll db:(FMDatabase *)db
{
    if(!poll)
    {
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from polls_options where pollKey=%d", poll.key];
    
    poll = [GLPPollDaoParser updateWithOptionsVotesFromResultSet:resultSet withPoll:poll inDb:db];
    
    return poll;
}

/**
 Finds options names and keys and returns a dictionary with key as key and option as value.
 
 @param pollKey the key of poll.
 @param db database instance.
 
 @return dictionary contains option's key, name.
 
 */
+ (NSDictionary *)findOptionsKeysNamesWithPollKey:(NSInteger)pollKey db:(FMDatabase *)db
{
    NSMutableDictionary *optionKeysNames = [[NSMutableDictionary alloc] init];
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select key, option from polls_options where pollKey=%d", pollKey];
    
    while ([resultSet next]) {
        [optionKeysNames setObject:[resultSet stringForColumn:@"option"] forKey:@([resultSet intForColumn:@"key"])];
    }
    
    return optionKeysNames;
}


#pragma mark - Save operations

+ (BOOL)saveOrUpdatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey
{
    __block BOOL success = NO;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        success = [GLPPollDao saveOrUpdatePoll:entity withPostRemoteKey:postRemoteKey db:db];
        
    }];
    
    return success;
}

+ (BOOL)saveOrUpdatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db
{
    NSInteger pollKey = [GLPPollDao findPollKeyByPostRemoteKey:postRemoteKey db:db];
    
    
    if(pollKey != -1)
    {
        GLPPoll *oldPoll = [GLPPollDao findPollWithPostRemoteKey:postRemoteKey db:db];

        DDLogDebug(@"GLPPollDao : old poll %@", oldPoll);
        DDLogDebug(@"GLPPollDao : new poll %@", entity);

        //Update poll data.
        return [self updatePoll:entity withPostRemoteKey:postRemoteKey db:db];
    }
    
    NSInteger expirationDate = [entity.expirationDate timeIntervalSince1970];
    
    BOOL success = [db executeUpdateWithFormat:@"insert into polls (postRemoteKey, expiration, users_vote) values(%d, %d, %@)",
     postRemoteKey,
     expirationDate,
     entity.usersVote];
    
    entity.key = [db lastInsertRowId];

    [self savePollOptionsWithPoll:entity db:db];
    
    return success;
}

+ (void)savePollOptionsWithPoll:(GLPPoll *)poll db:(FMDatabase *)db
{    
    for(NSString *option in poll.options)
    {
        NSInteger vote = [[poll.votes objectForKey:option] integerValue];

        [db executeUpdateWithFormat:@"insert into polls_options (pollKey, option, votes) values(%d, %@, %d)",
         poll.key,
         option,
         vote];
    }
}

+ (void)savePollBeforeSent:(GLPPoll *)poll
{
    //TODO: Implementation pending.
}



#pragma mark - Update operations

+ (void)updatePollAfterSent:(GLPPoll *)poll
{
    //TODO: Implementation pending.
}

+ (void)updatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPPollDao updatePoll:entity withPostRemoteKey:postRemoteKey db:db];
        
    }];
}

+ (BOOL)updatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db
{
    NSAssert(postRemoteKey != 0, @"Update entity without post remote key");
    
    BOOL operationSuccess = NO;
    
    NSInteger expirationDate = [entity.expirationDate timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"update polls set expiration=%d, users_vote=%@ where postRemoteKey=%d",
     expirationDate,
     entity.usersVote,
     postRemoteKey];
    
    entity.key = [GLPPollDao findPollKeyByPostRemoteKey:postRemoteKey db:db];
    
    NSDictionary *optionsKeysNames = [GLPPollDao findOptionsKeysNamesWithPollKey:entity.key db:db];
    
    for(NSNumber *key in optionsKeysNames)
    {
        NSString *name = [optionsKeysNames objectForKey:key];
        NSInteger vote = [[entity.votes objectForKey:name] integerValue];
                
        operationSuccess = [db executeUpdateWithFormat:@"update polls_options set votes=%d where key=%d",
         vote,
         [key integerValue]];
    }
    
    return operationSuccess;
}

#pragma mark - Delete

+ (BOOL)deletePollWithPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db
{
    NSInteger pollToBeDeletedKey = [GLPPollDao findPollKeyByPostRemoteKey:postRemoteKey db:db];
    
    BOOL s1 = [db executeUpdateWithFormat:@"delete from polls where postRemoteKey=%d",
     postRemoteKey];
    
    BOOL s2 = [db executeUpdateWithFormat:@"delete from polls_options where pollKey=%d",
     pollToBeDeletedKey];
    
    return (s1 && s2);
}

+ (BOOL)deletePollWithPostRemoteKey:(NSInteger)postRemoteKey
{
    __block BOOL success = NO;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        success = [GLPPollDao deletePollWithPostRemoteKey:postRemoteKey db:db];
        
    }];
    
    return success;
}

@end
