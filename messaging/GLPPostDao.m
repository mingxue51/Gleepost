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
#import "GLPCategoryDao.h"
#import "GLPVideo.h"

@implementation GLPPostDao


#pragma mark - Load operations

+ (NSArray *)findLastPostsInDb:(FMDatabase *)db
{
    // order by date, and if date is similar, second ordering by remoteKey
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts order by date desc, remoteKey desc limit %d", kGLPNumberOfPosts];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
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
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];

    
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
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    
    
    return result;
}

+(void)loadImagesWithPosts:(NSMutableArray *)posts withDb:(FMDatabase *)db
{
    for(GLPPost *currentPost in posts)
    {
        FMResultSet *imagesResultSet = [db executeQueryWithFormat:@"select image_url from post_images where post_remote_key=%d", currentPost.remoteKey];
        
        NSMutableArray *imagesUrl = [NSMutableArray array];
        
        while ([imagesResultSet next])
        {
            [imagesUrl addObject:[imagesResultSet stringForColumn:@"image_url"]];
            
            currentPost.imagesUrls = [imagesUrl mutableCopy];
        }
    }
}

+(void)loadVideosWithPosts:(NSMutableArray *)posts withDb:(FMDatabase *)db
{
    for(GLPPost *currentPost in posts)
    {
        FMResultSet *videoResultSet = [db executeQueryWithFormat:@"select * from post_videos where post_remote_key=%d", currentPost.remoteKey];
        
//        NSMutableArray *videoData = [NSMutableArray array];
        
        while ([videoResultSet next])
        {
//            [videosUrl addObject:[imagesResultSet stringForColumn:@"video_url"]];
            
            NSString *videoUrl = [videoResultSet stringForColumn:@"video_url"];
            NSString *thumbnailUrl = [videoResultSet stringForColumn:@"video_thumbnail_url"];
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *tempId = [f numberFromString:[videoResultSet stringForColumn:@"video_temp_key"]];
            
            currentPost.video = [[GLPVideo alloc] initWithUrl:videoUrl andThumbnailUrl:thumbnailUrl];
            
            if(tempId)
            {
                currentPost.video.pendingKey = tempId;
            }
        }
    }
}

+(NSArray*)likedPostsInDb:(FMDatabase*)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where liked=1"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return result;
}

#pragma mark - Save operations

+ (void)save:(GLPPost *)entity inDb:(FMDatabase *)db
{
    int date = [entity.date timeIntervalSince1970];
    int eventDate = [entity.dateEventStarts timeIntervalSince1970];
    
    BOOL postSaved;
    
    if(entity.remoteKey == 0) {
        postSaved = [db executeUpdateWithFormat:@"insert into posts (content, date, likes, dislikes, comments, sendStatus, author_key, liked, attending, event_title, event_date) values(%@, %d, %d, %d, %d, %d, %d, %d, %d, %@, %d)",
                     entity.content,
                     date,
                     entity.likes,
                     entity.dislikes,
                     entity.commentsCount,
                     entity.sendStatus,
                     entity.author.remoteKey,
                     entity.liked,
                     entity.attended,
                     entity.eventTitle,
                     eventDate];
    } else {
        postSaved = [db executeUpdateWithFormat:@"insert into posts (remoteKey, content, date, likes, dislikes, comments, sendStatus, author_key, liked, attending, event_title, event_date) values(%d, %@, %d, %d, %d, %d, %d, %d, %d, %d, %@, %d)",
                     entity.remoteKey,
                     entity.content,
                     date,
                     entity.likes,
                     entity.dislikes,
                     entity.commentsCount,
                     entity.sendStatus,
                     entity.author.remoteKey,
                     entity.liked,
                     entity.attended,
                     entity.eventTitle,
                     eventDate];
    }
    
    entity.key = [db lastInsertRowId];
    
    
    [GLPPostDao insertCategoriesWithEntity:entity andDb:db];
    
    if([entity imagePost])
    {
        [GLPPostDao insertImagesWithEntity:entity andDb:db];
    }

    if([entity isVideoPost])
    {
        [GLPPostDao insertVideosWithEntity:entity andDb:db];
    }
    
    
    //Save the author.
    [GLPUserDao saveIfNotExist:entity.author db:db];
}

+(void)insertCategoriesWithEntity:(GLPPost *)entity andDb:(FMDatabase *)db
{
    if(entity.remoteKey != 0)
    {
        //Insert post's categories.
        for(GLPCategory *category in entity.categories)
        {
            category.postRemoteKey = entity.remoteKey;
            [GLPCategoryDao saveCategoryIfNotExist:category db:db];
        }
    }
}

+(void)insertImagesWithEntity:(GLPPost *)entity andDb:(FMDatabase *)db
{
    for(NSString* imageUrl in entity.imagesUrls)
    {
        [db executeUpdateWithFormat:@"insert into post_images (post_remote_key, image_url) values(%d, %@)",
         entity.remoteKey,
         imageUrl];
    }
}

+ (void)insertVideosWithEntity:(GLPPost *)entity andDb:(FMDatabase *)db
{
    BOOL s = [db executeUpdateWithFormat:@"insert into post_videos (post_remote_key, video_url, video_thumbnail_url, video_temp_key) values(%d, %@, %@, %d)",
     entity.remoteKey,
     entity.video.url,
     entity.video.thumbnailUrl,
    [entity.video.pendingKey intValue]];
    
    DDLogDebug(@"Video data inserted: %d : %@", s, entity.video);
    
//    for(NSString* videoUrl in entity.videosUrls)
//    {
//        [db executeUpdateWithFormat:@"insert into post_videos (post_remote_key, video_url) values(%d, %@)",
//         entity.remoteKey,
//         videoUrl];
//    }
}

#pragma mark - Update operations

+(void)updateLikedStatusWithPost:(GLPPost*)entity inDb:(FMDatabase*)db
{
    [db executeUpdateWithFormat:@"update posts set liked=%d where remoteKey=%d",
     entity.liked,
     entity.remoteKey];
}


+(void)updatePostAttending:(GLPPost*)entity db:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"update posts set attending=%d where remoteKey=%d",
     entity.attended,
     entity.remoteKey];
}

+(void)updateCommentStatusWithNumberOfComments:(int)number andPostRemoteKey:(int)remoteKey inDb:(FMDatabase*)db
{
    BOOL ex = [db executeUpdateWithFormat:@"update posts set comments=%d where remoteKey=%d",
     number,
     remoteKey];
    
    NSLog(@"updateCommentStatusWithNumberOfComments: %d",ex);
}

+ (void)updatePostSendingData:(GLPPost *)entity inDb:(FMDatabase *)db
{
    NSAssert(entity.key != 0, @"Update entity without key");
    
    if(entity.remoteKey != 0)
    {
        DDLogDebug(@"updatePostSendingData remote key not zero");
        [db executeUpdateWithFormat:@"update posts set remoteKey=%d, sendStatus=%d where key=%d",
         entity.remoteKey,
         entity.sendStatus,
         entity.key];
        
    } else
    {
        DDLogDebug(@"updatePostSendingData remote key zero");
        [db executeUpdateWithFormat:@"update posts set sendStatus=%d where key=%d",
         entity.sendStatus,
         entity.key];
    }
    
    
    //Insert post's categories.
    for(GLPCategory *category in entity.categories)
    {
        category.postRemoteKey = entity.remoteKey;        
        [GLPCategoryDao saveCategoryIfNotExist:category db:db];
    }
}

+ (void)updateVideoPostSendingData:(GLPPost *)entity inDb:(FMDatabase *)db
{
    [GLPPostDao updatePostSendingData:entity inDb:db];
    
    if(entity.remoteKey != 0)
    {
        [GLPPostDao insertVideosWithEntity:entity andDb:db];
    }
    
}

#pragma makr - Delete operations

+(void)deletePostWithPost:(GLPPost *)entity db:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"delete from posts where remoteKey=%d",
     entity.remoteKey];
}

+ (void)deleteAllInDb:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"delete from posts"];
    
    [db executeUpdateWithFormat:@"delete from post_images"];
    
    [db executeUpdateWithFormat:@"delete from post_videos"];
}

@end
