//
//  GLPReviewHistoryDao.m
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPReviewHistoryDao.h"
#import "FMResultSet.h"
#import "DatabaseManager.h"
#import "GLPReviewHistory.h"
#import "GLPReviewHistoryDaoParser.h"
#import "GLPPost.h"
#import "GLPUserDao.h"

@implementation GLPReviewHistoryDao

+ (NSArray *)findReviewHistoryWithPostRemoteKey:(NSInteger)postRemoteKey
{
    __block NSArray *reviewHistories = [[NSMutableArray alloc] init];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        reviewHistories = [GLPReviewHistoryDao findReviewHistoryWithPostRemoteKey:postRemoteKey db:db];
    }];
    
    return reviewHistories;
}

+ (NSArray *)findReviewHistoryWithPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db
{
    NSMutableArray *reviewHistories = [[NSMutableArray alloc] init];
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from review_history where post_remote_key=%d order by date desc", postRemoteKey];
    
    while ([resultSet next])
    {
        GLPReviewHistory *currentReviewHistory = [GLPReviewHistoryDaoParser createFromResultSet:resultSet inDb:db];
        [reviewHistories addObject:currentReviewHistory];
    }
    
    return reviewHistories;
}

+ (void)saveReviewHistory:(GLPReviewHistory *)reviewHistory withPost:(GLPPost *)post
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        [GLPReviewHistoryDao save:reviewHistory withPostRemoteKey:post.remoteKey inDb:db];
        
    }];
}

+ (void)saveReviewHistoryArrayOfPost:(GLPPost *)post
{
    if(post.reviewHistory)
    {
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            
            for(GLPReviewHistory *reviewH in post.reviewHistory)
            {
                [GLPReviewHistoryDao save:reviewH withPostRemoteKey:post.remoteKey inDb:db];
            }
        }];
    }
}

+ (void)save:(GLPReviewHistory *)entity withPostRemoteKey:(NSInteger)postRemoteKey inDb:(FMDatabase *)db
{
    NSAssert(postRemoteKey != 0, @"Remote key of entity should never be 0.");

    BOOL reviewSaved = [db executeUpdateWithFormat:@"insert into review_history (post_remote_key, date, reason, action, user_remote_key) values(%d, %d, %@, %d, %d)",
     postRemoteKey,
     entity.dateHappened,
     entity.reason,
     entity.action,
     entity.user.remoteKey];
    
    entity.key = [db lastInsertRowId];
    
    //Save the author.
    [GLPUserDao saveIfNotExist:entity.user db:db];
    
    DDLogDebug(@"Review saved with status %d", reviewSaved);
}

+ (void)removeReviewHistoryWithPost:(GLPPost *)post
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        BOOL removed = [db executeUpdateWithFormat:@"delete from review_history where post_remote_key=%d",
         post.remoteKey];
        
        DDLogDebug(@"History removed %d", removed);
        
    }];
}

+ (void)deleteReviewHistoryTable
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        BOOL removed = [db executeUpdateWithFormat:@"delete from review_history"];
        
        NSAssert(removed, @"Review history table has not being removed as expected.");
    }];
}

@end
