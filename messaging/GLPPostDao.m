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
#import "GLPUserDao.h"
#import "DatabaseManager.h"

@implementation GLPPostDao

+ (NSArray *)findLastPostsInDb:(FMDatabase *)db
{
    // order by date, and if date is similar, second ordering by remoteKey
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts order by date desc, remoteKey desc limit %d", kGLPNumberOfPosts];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    //Fetch post images from database.
    for(GLPPost *currentPost in result)
    {
        FMResultSet *imagesResultSet = [db executeQueryWithFormat:@"select image_url from post_images where post_remote_key=%d",currentPost.remoteKey];
        
        NSMutableArray *imagesUrl = [NSMutableArray array];
        
        while ([imagesResultSet next])
        {
            [imagesUrl addObject:[imagesResultSet stringForColumn:@"image_url"]];
            
            currentPost.imagesUrls = [imagesUrl mutableCopy];
        }
    }
    
    return result;
}

+ (NSArray *)findLastPostsAfter:(GLPPost *)post inDb:(FMDatabase *)db
{
    if(!post) {
        return [GLPPostDao findLastPostsInDb:db];
    }
    
    // get posts where date < post submit date if post is local
    // otherwise get where remoteKey < post key
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where (date < %d and remoteKey is null) or (remoteKey is not null and remoteKey < %d) order by date desc, remoteKey desc limit %d", post.date, post.remoteKey, kGLPNumberOfPosts];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (NSArray *)findAllPostsBefore:(GLPPost *)post inDb:(FMDatabase *)db
{
    if(!post) {
        return [GLPPostDao findLastPostsInDb:db];
    }
    
    // get posts where date < post submit date if post is local
    // otherwise get where remoteKey < post key
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where (date > %d and remoteKey is null) or (remoteKey is not null and remoteKey > %d) order by date desc, remoteKey desc", post.date, post.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

+ (void)save:(GLPPost *)entity inDb:(FMDatabase *)db
{
    int date = [entity.date timeIntervalSince1970];
    
    BOOL postSaved;
    
    if(entity.remoteKey == 0) {
        postSaved = [db executeUpdateWithFormat:@"insert into posts (content, date, likes, dislikes, comments, sendStatus, author_key) values(%@, %d, %d, %d, %d, %d, %d)",
                     entity.content,
                     date,
                     entity.likes,
                     entity.dislikes,
                     entity.commentsCount,
                     entity.sendStatus,
                     entity.author.remoteKey];
    } else {
        postSaved = [db executeUpdateWithFormat:@"insert into posts (remoteKey, content, date, likes, dislikes, comments, sendStatus, author_key) values(%d, %@, %d, %d, %d, %d, %d, %d)",
                     entity.remoteKey,
                     entity.content,
                     date,
                     entity.likes,
                     entity.dislikes,
                     entity.commentsCount,
                     entity.sendStatus,
                     entity.author.remoteKey];
    }
    
    entity.key = [db lastInsertRowId];
    
    
     
    //Insert images
    for(NSString* imageUrl in entity.imagesUrls)
    {
        [db executeUpdateWithFormat:@"insert into post_images (post_remote_key, image_url) values(%d, %@)",
         entity.remoteKey,
         imageUrl];
    }
    
    //Save the author.
    [GLPUserDao saveIfNotExist:entity.author db:db];
}

+ (void)updatePostSendingData:(GLPPost *)entity inDb:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Update entity without key");
    
    if(entity.remoteKey != 0) {
        [db executeUpdateWithFormat:@"update posts set remoteKey=%d, sendStatus=%d where key=%d",
         entity.remoteKey,
         entity.sendStatus,
         entity.key];
    } else {
        [db executeUpdateWithFormat:@"update posts set sendStatus=%d where key=%d",
         entity.sendStatus,
         entity.key];
    }
}

+ (void)deleteAllInDb:(FMDatabase *)db
{
    [db executeQuery:@"delete from posts"];
    [db executeQuery:@"delete from post_images"];
}

@end