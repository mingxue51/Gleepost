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
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts order by remoteKey desc limit %d", kGLPNumberOfPosts];
    
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

    BOOL postSaved = [db executeUpdateWithFormat:@"insert into posts (remoteKey, content, date, likes, dislikes, comments, author_key) values(%d, %@, %d, %d, %d, %d, %d)",
     entity.remoteKey,
     entity.content,
     date,
     entity.likes,
     entity.dislikes,
     entity.commentsCount,
     entity.author.remoteKey];
    
    entity.key = [db lastInsertRowId];
    
    NSLog(@"Post Saved: %d",postSaved);
     
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

@end
