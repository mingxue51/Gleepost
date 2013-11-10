//
//  GLPPostDao.m
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostDao.h"
#import "FMResultSet.h"
#import "GLPPostManager.h"
#import "GLPPostDaoParser.h"

@implementation GLPPostDao

+ (NSArray *)findLastPostsInDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts order by remoteKey desc limit %d", kGLPNumberOfPosts];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (NSArray *)findLastPostsBefore:(GLPPost *)post inDb:(FMDatabase *)db
{
    if(!post) {
        return [GLPPostDao findLastPostsInDb:db];
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where remoteKey < %d order by remoteKey desc limit %d", post.remoteKey, kGLPNumberOfPosts];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (void)save:(GLPPost *)entity inDb:(FMDatabase *)db
{
    int date = [entity.date timeIntervalSince1970];

    [db executeUpdateWithFormat:@"insert into posts (remoteKey, content, date, likes, dislikes, comments, author_key) values(%d, %@, %d, %d, %d, %d, %d)",
     entity.remoteKey,
     entity.content,
     date,
     entity.likes,
     entity.dislikes,
     entity.commentsCount,
     entity.author.remoteKey];
    
    entity.key = [db lastInsertRowId];
}

@end
