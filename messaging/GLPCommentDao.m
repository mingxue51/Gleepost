//
//  GLPCommentDao.m
//  Gleepost
//
//  Created by Silouanos on 25/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCommentDao.h"
#import "GLPUserDao.h"
#import "GLPCommentDaoParser.h"
#import "DatabaseManager.h"

@implementation GLPCommentDao

+ (NSArray *)findCommentsByPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db
{
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from comments where post_remote_key=%d",postRemoteKey];
    
    while ([resultSet next])
    {
        GLPComment *currentComment = [GLPCommentDaoParser createFromResultSet:resultSet inDb:db];
        
        //Load user's details for current comment.
        currentComment.author = [GLPUserDao findByRemoteKey:currentComment.remoteKey db:db];
        
        [comments addObject: currentComment];
        
    }
    
    return comments;
}

+ (GLPComment *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from comments where remote_key=%d", remoteKey];
    
    GLPComment *comment = nil;
    
    if([resultSet next]) {
        
        comment = [GLPCommentDaoParser createFromResultSet:resultSet inDb:db];
    }
    
    return comment;
}

+ (void)save:(GLPComment *)entity
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPCommentDao save:entity inDb:db];
        
    }];

}

+ (void)save:(GLPComment *)entity inDb:(FMDatabase *)db
{
    DDLogDebug(@"Comment: %@", entity);
    
    int date = entity.date.timeIntervalSince1970;
    
    if(entity.remoteKey == 0)
    {
        [db executeUpdateWithFormat:@"insert into comments (post_remote_key, content, date, user_remote_key, image_url, send_status) values(%d, %@, %d, %d, %@, %d)",
         entity.post.remoteKey,
         entity.content,
         date,
         entity.author.remoteKey,
         entity.content,
         entity.sendStatus];
        
        
        /**
         
         
         [db executeUpdateWithFormat:@"insert into posts (content, date, likes, dislikes, comments, sendStatus, author_key, liked) values(%@, %d, %d, %d, %d, %d, %d, %d)",
         entity.content,
         date,
         entity.likes,
         entity.dislikes,
         entity.commentsCount,
         entity.sendStatus,
         entity.author.remoteKey,
         entity.liked];
         
         
         */
        
    }
    else
    {
        [db executeUpdateWithFormat:@"insert into comments(remote_key, post_remote_key, content, date, user_remote_key, image_url, send_status) values(%d, %d, %@, %d, %d, %@, %d)", entity.remoteKey, entity.post.remoteKey, entity.content, entity.date.timeIntervalSince1970, entity.author.remoteKey, @"", entity.sendStatus];
    }

    
    entity.key = [db lastInsertRowId];
    
    //Save the author.
    [GLPUserDao saveIfNotExist:entity.author db:db];
}

+ (void)updateCommentSendingData:(GLPComment *)entity
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [self updateCommentSendingData:entity inDb:db];
        
    }];
}

+ (void)updateCommentSendingData:(GLPComment *)entity inDb:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Update entity without key");
    
    BOOL success = NO;
    
    if(entity.remoteKey != 0)
    {
        success = [db executeUpdateWithFormat:@"update comments set remote_key=%d, send_status=%d where key=%d",
         entity.remoteKey,
         entity.sendStatus,
         entity.key];
        
    } else
    {
        success = [db executeUpdateWithFormat:@"update comments set send_status=%d where key=%d",
         entity.sendStatus,
         entity.key];
    }
}


@end
