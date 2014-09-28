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
#import "GLPLocation.h"

@implementation GLPPostDao


#pragma mark - Load operations

+ (NSArray *)findLastPostsInDb:(FMDatabase *)db
{
    // order by date, and if date is similar, second ordering by remoteKey
 
    
//    FMResultSet *resultSet2 = [db executeQueryWithFormat:@"select * from posts order by date desc, remoteKey desc limit %d", kGLPNumberOfPosts];
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where sendStatus = 3 AND group_remote_key = 0 order by date desc, remoteKey desc limit %d", kGLPNumberOfPosts];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    DDLogDebug(@"findLastPostsInDb");
    
    for(GLPPost *p in result)
    {
        DDLogDebug(@"-> %@", p.content);
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
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where (date < %d and remoteKey is null) or (remoteKey is not null and remoteKey < %d) AND group_remote_key = 0 order by date desc, remoteKey desc limit %d", post.date, post.remoteKey, kGLPNumberOfPosts];
    
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
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where (date > %d and remoteKey is null) or (remoteKey is not null and remoteKey > %d) AND group_remote_key = 0 order by date desc, remoteKey desc", post.date, post.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    
    
    return result;
}

+ (NSInteger)findPostKeyByRemoteKey:(NSInteger)remoteKey inDB:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where remoteKey=%d limit 1", remoteKey];
    
    NSInteger postKey = -1;
    
    if([resultSet next]) {
        GLPPost *p = [GLPPostDaoParser createFromResultSet:resultSet inDb:db];
        postKey = p.key;
    }
    
    return postKey;
    
}

+ (NSArray *)findPostsInGroupWithRemoteKey:(NSInteger)groupRemoteKey inDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where sendStatus = 3 AND group_remote_key = %d order by date desc, remoteKey desc limit %d", groupRemoteKey, kGLPNumberOfPosts];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    return result;
}

+ (NSArray *)findAllPendingPostsWithVideosInDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where sendStatus = %d", kSendStatusLocal];
    
    NSMutableArray *posts = [NSMutableArray array];
    
    while ([resultSet next])
    {
        [posts addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    return [GLPPostDao findValidVideoPosts:posts withDb:db];;
}

+ (NSArray *)findValidVideoPosts:(NSArray *)posts withDb:(FMDatabase *)db
{
    NSMutableArray *videoPosts = [[NSMutableArray alloc] init];
    
    for(GLPPost *currentPost in posts)
    {
        FMResultSet *videoResultSet = [db executeQueryWithFormat:@"select * from post_videos where video_temp_key != -1"];
        
        while ([videoResultSet next])
        {
            NSString *videoUrl = [videoResultSet stringForColumn:@"video_url"];
            NSString *thumbnailUrl = [videoResultSet stringForColumn:@"video_thumbnail_url"];
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *tempId = [f numberFromString:[videoResultSet stringForColumn:@"video_temp_key"]];
            
            
            currentPost.video = [[GLPVideo alloc] init];
            
            if(!videoUrl && !thumbnailUrl)
            {
                currentPost.video.pendingKey = tempId;
                
                [videoPosts addObject:currentPost];
                
            }
        }
    }
    
    return videoPosts;
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
            
//            currentPost.video = [[GLPVideo alloc] initWithUrl:videoUrl andThumbnailUrl:thumbnailUrl];
            
            currentPost.video = [[GLPVideo alloc] init];
            
            currentPost.video.url = videoUrl;
            currentPost.video.thumbnailUrl = thumbnailUrl;
            
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
    NSInteger postKey = [GLPPostDao findPostKeyByRemoteKey:entity.remoteKey inDB:db];
    
    if(postKey != -1)
    {
        entity.key = postKey;
        //Update post.
        [GLPPostDao updatePost:entity inDb:db];
        
        return;
    }
    
    int date = [entity.date timeIntervalSince1970];
    
    int eventDate = [entity.dateEventStarts timeIntervalSince1970];
    
    int groupRemoteKey = entity.group ? entity.group.remoteKey : 0;
    
    BOOL postSaved;
    
    if(entity.remoteKey == 0) {
        postSaved = [db executeUpdateWithFormat:@"insert into posts (content, date, likes, dislikes, comments, sendStatus, author_key, liked, attending, event_title, event_date, location_lat, location_lon, location_name, location_address, group_remote_key) values(%@, %d, %d, %d, %d, %d, %d, %d, %d, %@, %d, %f, %f, %@, %@, %d)",
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
                     eventDate,
                     entity.location.latitude,
                     entity.location.longitude,
                     entity.location.name,
                     entity.location.address,
                     groupRemoteKey];
    } else {
        postSaved = [db executeUpdateWithFormat:@"insert into posts (remoteKey, content, date, likes, dislikes, comments, sendStatus, author_key, liked, attending, event_title, event_date, location_lat, location_lon, location_name, location_address, group_remote_key) values(%d, %@, %d, %d, %d, %d, %d, %d, %d, %d, %@, %d, %f, %f, %@, %@, %d)",
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
                     eventDate,
                     entity.location.latitude,
                     entity.location.longitude,
                     entity.location.name,
                     entity.location.address,
                     groupRemoteKey];
    }
    
    
    entity.key = [db lastInsertRowId];
    
   DDLogDebug(@"Post saved with status: %d and content: %@ location: %@ group: %@", entity.sendStatus, entity.content, entity.location, entity.group);
    
    
    [GLPPostDao insertCategoriesWithEntity:entity andDb:db];
    
    if([entity imagePost])
    {
        [GLPPostDao insertImagesWithEntity:entity andDb:db];
    }

    if([entity isVideoPost])
    {
        [GLPPostDao saveVideoWithEntity:entity inDb:db];
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

+ (void)saveVideoWithEntity:(GLPPost *)entity inDb:(FMDatabase *)db
{
    BOOL s = [db executeUpdateWithFormat:@"replace into post_videos (post_remote_key, post_key, video_url, video_thumbnail_url, video_temp_key) values(%d, %d, %@, %@, %d)",
              entity.remoteKey,
              entity.key,
              entity.video.url,
              entity.video.thumbnailUrl,
              -1];
    
    DDLogDebug(@"Video data replaced (status %d): %d : %@ : post key: %ld", entity.sendStatus, s, entity.video, (long)entity.key);
}

+ (void)insertVideoWithEntity:(GLPPost *)entity andDb:(FMDatabase *)db
{
//    if(entity.remoteKey == 0)
//    {
        if(!entity.video.pendingKey)
        {
            return;
        }
    
    BOOL s = [db executeUpdateWithFormat:@"update post_videos set video_temp_key=%d where post_key=%d",
              [entity.video.pendingKey intValue],
              entity.key];
    
//        BOOL s = [db executeUpdateWithFormat:@"insert into post_videos (post_remote_key, post_key, video_url, video_thumbnail_url, video_temp_key) values(%d, %d, %@, %@, %d)",
//                  entity.remoteKey,
//                  entity.key,
//                  entity.video.url,
//                  entity.video.thumbnailUrl,
//                  [entity.video.pendingKey intValue]];
    
        DDLogDebug(@"Video data inserted (status local): %d : %@, post key: %ld", s, entity.video, (long)entity.key);
//    }
//    else
//    {


//    }
    

    
//    for(NSString* videoUrl in entity.videosUrls)
//    {
//        [db executeUpdateWithFormat:@"insert into post_videos (post_remote_key, video_url) values(%d, %@)",
//         entity.remoteKey,
//         videoUrl];
//    }
}

+ (void)saveGroupPosts:(NSArray *)groupPosts
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        for(GLPPost *post in groupPosts)
        {
            post.sendStatus = kSendStatusSent;
            [GLPPostDao save:post inDb:db];
        }
    }];
}

+ (void)updateVideosWithEntity:(GLPPost *)entity andDb:(FMDatabase *)db
{
    if(!entity.video.url)
    {
        return;
    }
    
    BOOL s = [db executeUpdateWithFormat:@"update post_videos set post_remote_key=%d, video_url=%@, video_thumbnail_url=%@ where post_key=%d",
     entity.remoteKey,
     entity.video.url,
     entity.video.thumbnailUrl,
     entity.key];
    
//    BOOL s = [db executeUpdateWithFormat:@"update post_videos (post_remote_key, post_key, video_url, video_thumbnail_url, video_temp_key) values(%d, %d, %@, %@, %d)",
//              entity.remoteKey,
//              entity.key,
//              entity.video.url,
//              entity.video.thumbnailUrl,
//              [entity.video.pendingKey intValue]];
    
    DDLogDebug(@"Video data updated (status sent): %d : %@", s, entity.video);
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

+ (void)updatePost:(GLPPost *)entity inDb:(FMDatabase *)db
{
    NSAssert(entity.remoteKey != 0, @"Update entity without remote key");

    int date = [entity.date timeIntervalSince1970];
    
    int eventDate = [entity.dateEventStarts timeIntervalSince1970];
    
    [db executeUpdateWithFormat:@"update posts set content=%@, date=%d, likes=%d, dislikes=%d, comments=%d, sendStatus=%d, author_key=%d, liked=%d, attending=%d, event_title=%@, event_date=%d where remoteKey=%d",
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
     eventDate,
     entity.remoteKey];
}

+ (void)updateVideoPostSendingData:(GLPPost *)entity inDb:(FMDatabase *)db
{
    [GLPPostDao updatePostSendingData:entity inDb:db];
    
    DDLogDebug(@"updateVideoPostSendingData post key: %d :%@", entity.key, entity.content);
    
    if(entity.remoteKey != 0)
    {
        [GLPPostDao updateVideosWithEntity:entity andDb:db];
    }
    else
    {
        [GLPPostDao insertVideoWithEntity:entity andDb:db];
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
    DDLogInfo(@"Post table deleted.");
    
    [db executeUpdateWithFormat:@"delete from posts"];
    
    [db executeUpdateWithFormat:@"delete from post_images"];
    
    [db executeUpdateWithFormat:@"delete from post_videos"];
}

@end
