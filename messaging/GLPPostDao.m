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
#import "CategoryManager.h"
#import "GLPReviewHistoryDaoParser.h"
#import "GLPPollDao.h"

@implementation GLPPostDao


#pragma mark - Load operations

+ (NSArray *)findLastPostsInDb:(FMDatabase *)db
{
    // order by date, and if date is similar, second ordering by remoteKey
 
    
//    FMResultSet *resultSet2 = [db executeQueryWithFormat:@"select * from posts order by date desc, remoteKey desc limit %d", kGLPNumberOfPosts];
    
    FMResultSet *resultSet = [self lastPostsFromSelectedCategoryWithDb:db];
    
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        
        GLPPost *post = [GLPPostDaoParser createFromResultSet:resultSet inDb:db];
        

        [result addObject:post];

    }
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    [GLPPostDao loadPollPostDataIfNeededWithPosts:result db:db];
    
    return result;
}

+ (NSArray *)findLastPostsAfter:(GLPPost *)post inDb:(FMDatabase *)db
{
    if(!post) {
        return [GLPPostDao findLastPostsInDb:db];
    }
    
    DDLogDebug(@"Find last posts after: %@", post);
    
    // get posts where date < post submit date if post is local
    // otherwise get where remoteKey < post key
//    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where (date < %d and remoteKey is null) or (remoteKey is not null and remoteKey < %d) AND group_remote_key = 0 order by date desc, remoteKey desc limit %d", post.date, post.remoteKey, kGLPNumberOfPosts];
    
    FMResultSet *resultSet = [self lastPostsAfterPost:post fromSelectedCategoryWithDb:db];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];

    [GLPPostDao loadPollPostDataIfNeededWithPosts:result db:db];
    
    return result;
}

+ (NSArray *)findAllPostsBefore:(GLPPost *)post inDb:(FMDatabase *)db
{
    if(!post) {
        return [GLPPostDao findLastPostsInDb:db];
    }
    
    DDLogDebug(@"Find all posts before: %@", post);
    
    // get posts where date < post submit date if post is local
    // otherwise get where remoteKey < post key
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where (date > %d and remoteKey is null) or (remoteKey is not null and remoteKey > %d) AND group_remote_key = 0 order by date desc, remoteKey desc", post.date, post.remoteKey];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    [GLPPostDao loadPollPostDataIfNeededWithPosts:result db:db];
    
    return result;
}

+ (NSArray *)findPostsWithUsersRemoteKey:(NSInteger)usersRemoteKey
{
    __block NSArray *localPosts = nil;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        localPosts = [GLPPostDao findPostsWithUsersRemoteKey:usersRemoteKey inDb:db];
    }];
    
    return localPosts;
}

+ (NSArray *)findLastSentPosts
{
    __block NSArray *lastPosts = nil;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        lastPosts = [GLPPostDao findLastSentPostsWithDb:db];
    }];
    
    return lastPosts;
}

+ (NSArray *)findLastSentPostsWithDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where sendStatus = 3 AND group_remote_key = 0 AND pending = 0 order by date desc, remoteKey desc"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    [GLPPostDao loadPollPostDataIfNeededWithPosts:result db:db];
    
    return result;
}



+ (NSArray *)findLastPostsInAnySendStatus
{
    __block NSArray *lastPosts = nil;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        lastPosts = [GLPPostDao findLastPostsInAnySendStatusWithDb:db];
    }];
    
    return lastPosts;
}

+ (NSArray *)findLastPostsInAnySendStatusWithDb:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where group_remote_key = 0 AND pending = 0 order by date desc, remoteKey desc"];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    [GLPPostDao loadPollPostDataIfNeededWithPosts:result db:db];
    
    return result;
}



+ (NSArray *)findPostsWithUsersRemoteKey:(NSInteger)usersRemoteKey inDb:(FMDatabase *)db
{
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where sendStatus = 3 AND author_key = %d AND pending = 0 order by date desc, remoteKey desc limit %d", usersRemoteKey, kGLPNumberOfPosts];

    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    [GLPPostDao loadPollPostDataIfNeededWithPosts:result db:db];
    
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
    DDLogDebug(@"GLPPostDao findPostsInGroupWithRemoteKey : %d", groupRemoteKey);
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from posts where sendStatus = 3 AND group_remote_key = %d order by date desc, remoteKey desc limit %d", groupRemoteKey, kGLPNumberOfPosts];
    
    NSMutableArray *result = [NSMutableArray array];
    
    while ([resultSet next]) {
        [result addObject:[GLPPostDaoParser createFromResultSet:resultSet inDb:db]];
    }
    
    
    [GLPPostDao loadImagesWithPosts:result withDb:db];
    
    [GLPPostDao loadVideosWithPosts:result withDb:db];
    
    [GLPPostDao loadPollPostDataIfNeededWithPosts:result db:db];
    
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


+ (void)loadImagesWithPosts:(NSMutableArray *)posts withDb:(FMDatabase *)db
{
    for(GLPPost *currentPost in posts)
    {
        [GLPPostDao loadImagesWithPost:currentPost db:db];
    }
}

+ (void)loadPollPostDataIfNeededWithPosts:(NSMutableArray *)posts db:(FMDatabase *)db
{
    for(GLPPost *currentPost in posts)
    {
        currentPost.poll = [GLPPollDao findPollWithPostRemoteKey:currentPost.remoteKey db:db];
    }
}

+ (BOOL)loadImagesWithPost:(GLPPost *)post db:(FMDatabase *)db
{
    BOOL foundImages = NO;
    
    FMResultSet *imagesResultSet = [db executeQueryWithFormat:@"select image_url from post_images where post_remote_key=%d", post.remoteKey];
    
    NSMutableArray *imagesUrl = [NSMutableArray array];
    
    while ([imagesResultSet next])
    {
        [imagesUrl addObject:[imagesResultSet stringForColumn:@"image_url"]];
        
        post.imagesUrls = [imagesUrl mutableCopy];
        
        foundImages = YES;
    }
    
    return foundImages;
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

#pragma mark - Pending posts load operations

+ (NSArray *)loadPendingPosts
{
    __block NSMutableArray *pendingPosts = [[NSMutableArray alloc] init];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *resultSet = [self allPostsWaitingForApprovalWithDb:db];
        
        while ([resultSet next])
        {
            GLPPost *post = [GLPPostDaoParser createFromResultSet:resultSet inDb:db];
            
            post.reviewHistory = [GLPPostDao loadReviewHistoriesWithPost:post andDb:db];

            [pendingPosts addObject:post];
        }
        
        [GLPPostDao loadImagesWithPosts:pendingPosts withDb:db];
        [GLPPostDao loadVideosWithPosts:pendingPosts withDb:db];
        [GLPPostDao loadPollPostDataIfNeededWithPosts:pendingPosts db:db];
    }];
    
    return pendingPosts;
}


+ (NSMutableArray *)loadReviewHistoriesWithPost:(GLPPost *)post andDb:(FMDatabase *)db
{
    NSMutableArray *reviewHistories = [[NSMutableArray alloc] init];
    
    FMResultSet *resultSet = [GLPPostDao reviewHistoryWithPost:post andDb:db];
    
    while ([resultSet next]) {
        GLPReviewHistory *reviewHistory = [GLPReviewHistoryDaoParser createFromResultSet:resultSet inDb:db];
        [reviewHistories addObject:reviewHistory];
    }
    
    return reviewHistories;
}

#pragma mark - Save operations

+ (void)saveOrUpdatePost:(GLPPost *)entity
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPPostDao save:entity inDb:db];
    }];
}

/**
 Saves, updates or removes posts. In case of removing posts, the method
 compares the server's posts with database's posts, and removes any
 unnecessary posts. This method is for profile view controller.
 
 @param posts the remote posts.
 @param kindOfQuery the kind of query.
 */

+ (void)saveUpdateOrRemovePosts:(NSArray *)posts withCreatorRemoteKey:(NSInteger)userRemoteKey
{
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        NSArray *profilePosts = [GLPPostDao findPostsWithUsersRemoteKey:userRemoteKey inDb:db];
        
        DDLogDebug(@"GLPPostDao : Profile posts %@", profilePosts);

        
        NSArray *postsToDelete = [GLPPostDao subtractRemotePosts:posts withLocalPosts:profilePosts.mutableCopy];
        
        DDLogDebug(@"GLPPostDao : Posts to delete %@", postsToDelete);
        
        if(postsToDelete)
        {
            [GLPPostDao removePostsFromDatabase:postsToDelete withDb:db];
        }
        
        for(GLPPost *p in posts)
        {
            p.sendStatus = kSendStatusSent;
            [GLPPostDao save:p inDb:db];
        }
        
    }];
}

+ (NSArray *)saveUpdateOrRemovePostsInCW:(NSArray *)posts
{
    __block NSArray *deletedPosts = [[NSArray alloc] init];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSArray *campusWallPosts = [GLPPostDao findLastPostsInDb:db];
                
        NSArray *postsToDelete = [GLPPostDao subtractRemotePosts:posts withLocalPosts:campusWallPosts.mutableCopy];
        
        DDLogDebug(@"GLPPostDao : Posts to delete %@", postsToDelete);
        
        if(postsToDelete)
        {
            [GLPPostDao removePostsFromDatabase:postsToDelete withDb:db];
        }
        
        for(GLPPost *p in posts)
        {
            p.sendStatus = kSendStatusSent;
            [GLPPostDao save:p inDb:db];
        }
                
        deletedPosts = postsToDelete;
        
    }];
    
    return deletedPosts;
}

+ (void)saveUpdateOrRemovePosts:(NSArray *)posts withGroupRemoteKey:(NSInteger)groupRemoteKey
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSArray *groupPosts = [GLPPostDao findPostsInGroupWithRemoteKey:groupRemoteKey inDb:db];
        
        DDLogDebug(@"GLPPostDao : Group posts %@", groupPosts);
        
        NSArray *postsToDelete = [GLPPostDao subtractRemotePosts:posts withLocalPosts:groupPosts.mutableCopy];
        
        DDLogDebug(@"GLPPostDao : Group Posts to delete %@", postsToDelete);
        
        if(postsToDelete)
        {
            [GLPPostDao removePostsFromDatabase:postsToDelete withDb:db];
        }
        
        for(GLPPost *p in posts)
        {
            if(p.group == nil)
            {
                FLog(@"Post should have a group before save to local database %@", p.group);
                p.group = [[GLPGroup alloc] init];
                p.group.remoteKey = groupRemoteKey;
            }
            
            if(p.group.remoteKey == 0)
            {
                FLog(@"Group post group attribute should not be 0");
                p.group.remoteKey = groupRemoteKey;
            }
            
            p.sendStatus = kSendStatusSent;
            [GLPPostDao save:p inDb:db];
        }
    }];
}

+ (NSArray *)subtractRemotePosts:(NSArray *)remotePosts withLocalPosts:(NSMutableArray *)localPosts
{
    [localPosts removeObjectsInArray:remotePosts];
    
    DDLogDebug(@"GLPPostDao : subtractRemotePosts %d : %d", remotePosts.count, localPosts.count);

    if(localPosts.count == remotePosts.count)
    {
        return nil;
    }
    
    return localPosts;
}

+ (void)removePostsFromDatabase:(NSArray *)posts withDb:(FMDatabase *)db
{
    for(GLPPost *p in posts)
    {
        [GLPPostDao deletePostWithPost:p db:db];
    }
}

+ (NSArray *)getTheNewPostsWithRemotePosts:(NSArray *)remotePosts
{
    
    NSArray *allDatabasePosts = [GLPPostDao findLastPostsInAnySendStatus];
    
    NSArray *allSentDatabasePosts = [GLPPostDao findLastSentPosts];
    
    NSMutableArray *newPosts = remotePosts.mutableCopy;
    
    [newPosts removeObjectsInArray:allDatabasePosts];
    
    if(newPosts.count > 0)
    {
        if([(GLPPost *)[newPosts firstObject] remoteKey] < [(GLPPost *)[allSentDatabasePosts firstObject] remoteKey])
        {
            DDLogDebug(@"GLPPostDao : new post remote key smaller than the last.");
            
            return [NSArray array];
        }
    }
    
    DDLogDebug(@"GLPPostDao : new posts %@", newPosts);
    
    return newPosts;
}

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
    
    NSInteger groupRemoteKey = entity.group ? entity.group.remoteKey : 0;
    
    BOOL postSaved;
    
    if(entity.remoteKey == 0) {
        postSaved = [db executeUpdateWithFormat:@"insert into posts (content, date, likes, dislikes, comments, sendStatus, author_key, liked, attending, event_title, event_date, location_lat, location_lon, location_name, location_address, group_remote_key, pending) values(%@, %d, %d, %d, %d, %d, %d, %d, %d, %@, %d, %f, %f, %@, %@, %d, %d)",
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
                     groupRemoteKey,
                     entity.pendingInEditMode];
    } else {
        postSaved = [db executeUpdateWithFormat:@"insert into posts (remoteKey, content, date, likes, dislikes, comments, sendStatus, author_key, liked, attending, event_title, event_date, location_lat, location_lon, location_name, location_address, group_remote_key, pending) values(%d, %@, %d, %d, %d, %d, %d, %d, %d, %d, %@, %d, %f, %f, %@, %@, %d, %d)",
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
                     groupRemoteKey,
                     entity.pendingInEditMode];
    }
    
    
    entity.key = [db lastInsertRowId];
    
   DDLogInfo(@"Post saved with status: %d and content: %@ location: %@ group: %@", entity.sendStatus, entity.content, entity.location, entity.group);
    
    
    [GLPPostDao insertCategoriesWithEntity:entity andDb:db];
    
    if([entity imagePost])
    {
        [GLPPostDao insertImagesWithEntity:entity andDb:db];
    }

    if([entity isVideoPost])
    {
        [GLPPostDao saveVideoWithEntity:entity inDb:db];
    }
    
    if([entity isPollPost] && entity.remoteKey == 0)
    {
        [GLPPollDao savePollBeforeSent:entity.poll withPostKey:entity.key db:db];
    }
    else if([entity isPollPost] && entity.remoteKey != 0)
    {
        [GLPPollDao saveOrUpdatePoll:entity.poll withPostRemoteKey:entity.remoteKey db:db];
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
        [db executeUpdateWithFormat:@"replace into post_images (post_remote_key, image_url) values(%d, %@)",
         entity.remoteKey,
         imageUrl];
    }
}

+ (void)saveVideoWithEntity:(GLPPost *)entity inDb:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"replace into post_videos (post_remote_key, post_key, video_url, video_thumbnail_url, video_temp_key) values(%d, %d, %@, %@, %d)",
              entity.remoteKey,
              entity.key,
              entity.video.url,
              entity.video.thumbnailUrl,
              -1];
    
//    DDLogDebug(@"Video data replaced (status %d): %d : %@ : post key: %ld", entity.sendStatus, s, entity.video, (long)entity.key);
}

+ (void)insertVideoWithEntity:(GLPPost *)entity andDb:(FMDatabase *)db
{
        if(!entity.video.pendingKey)
        {
            return;
        }
    
    BOOL s = [db executeUpdateWithFormat:@"update post_videos set video_temp_key=%d where post_key=%d",
              [entity.video.pendingKey intValue],
              entity.key];
    
        DDLogDebug(@"Video data inserted (status local): %d : %@, post key: %ld", s, entity.video, (long)entity.key);
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

+ (void)updatePendingStatuswithPost:(GLPPost *)entity
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        BOOL pendingPostUpdated = [db executeUpdateWithFormat:@"update posts set pending=%d where key=%d",
         [entity isPendingInEditMode],
         entity.key];
        
        NSAssert(pendingPostUpdated, @"Pending post should exist in database before, in order to be updated.");
    }];
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
        
        [GLPPollDao updatePollAfterSent:entity.poll withPostKey:entity.key withRemoteKey:entity.remoteKey db:db];

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
    
    [db executeUpdateWithFormat:@"update posts set content=%@, date=%d, likes=%d, dislikes=%d, comments=%d, sendStatus=%d, author_key=%d, liked=%d, attending=%d, event_title=%@, event_date=%d, pending=%d where remoteKey=%d",
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
     entity.pendingInEditMode,
     entity.remoteKey];
    
    if([entity imagePost])
    {
        [GLPPostDao updateImagesWithEntity:entity db:db];
    }
    
    if([entity isPollPost])
    {
        DDLogDebug(@"GLPPostDao : updatePost");
        [GLPPollDao saveOrUpdatePoll:entity.poll withPostRemoteKey:entity.remoteKey db:db];
    }
    
    //TODO: Add operation to update video as well.
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

+ (void)updateImagesWithEntity:(GLPPost *)entity db:(FMDatabase *)db
{
//    if(![GLPPostDao loadImagesWithPost:entity db:db])
//    {
        //If there are not images of this post in database then insert them.
        [GLPPostDao insertImagesWithEntity:entity andDb:db];
//    }
}

#pragma mark - Delete operations

+(void)deletePostWithPost:(GLPPost *)entity db:(FMDatabase *)db
{
    BOOL b = [db executeUpdateWithFormat:@"delete from posts where remoteKey=%d",
     entity.remoteKey];
    
    [db executeUpdateWithFormat:@"delete from post_images where post_remote_key=%d",
     entity.remoteKey];
    
    [db executeUpdateWithFormat:@"delete from post_videos where post_remote_key=%d",
     entity.remoteKey];
    
    [db executeUpdateWithFormat:@"delete from review_history where post_remote_key=%d",
     entity.remoteKey];
    
    [GLPPollDao deletePollWithPostRemoteKey:entity.remoteKey db:db];
    
    DDLogDebug(@"GLPPostDao : deletePostWithPost %@ %ld - %d", entity.content, (long)entity.group.remoteKey, b);
}

+ (void)deletePostsWithGroupRemoteKey:(NSInteger)groupRemoteKey db:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"delete from posts where group_remote_key=%d", groupRemoteKey];
}

+ (void)deleteAllInDb:(FMDatabase *)db
{
    DDLogInfo(@"Post table deleted.");
    
    [db executeUpdateWithFormat:@"delete from posts"];
    
    [db executeUpdateWithFormat:@"delete from post_images"];
    
    [db executeUpdateWithFormat:@"delete from post_videos"];
}

#pragma mark - FMResultSet constructors

+ (FMResultSet *)lastPostsFromSelectedCategoryWithDb:(FMDatabase *)db
{
    FMResultSet *resultSet = nil;
    
    NSString *tag = [[CategoryManager sharedInstance] selectedCategory].tag;
    
    if([[CategoryManager sharedInstance] selectedCategory] == nil)
    {
        resultSet = [db executeQueryWithFormat:@"select * from posts where sendStatus = 3 AND group_remote_key = 0 AND pending = 0 order by date desc, remoteKey desc limit %d", kGLPNumberOfPosts];
    }
    else
    {
        resultSet = [db executeQueryWithFormat:@"select * from posts p INNER JOIN categories cat where p.sendStatus = 3 AND p.group_remote_key = 0 AND cat.tag = %@ AND cat.post_remote_key = p.remoteKey AND p.pending = 0 order by date desc, p.remoteKey desc limit %d", tag, kGLPNumberOfPosts];
    }
    
    return resultSet;
}

+ (FMResultSet *)lastPostsAfterPost:(GLPPost *)post fromSelectedCategoryWithDb:(FMDatabase *)db
{
    FMResultSet *resultSet = nil;
    
    NSString *tag = [[CategoryManager sharedInstance] selectedCategory].tag;
    
    if([[CategoryManager sharedInstance] selectedCategory] == nil)
    {
        resultSet = [db executeQueryWithFormat:@"select * from posts where (date < %d and remoteKey is null) or (remoteKey is not null and remoteKey < %d) AND group_remote_key = 0 AND p.pending = 0 order by date desc, remoteKey desc limit %d", post.date, post.remoteKey, kGLPNumberOfPosts];
    }
    else
    {
//        resultSet = [db executeQueryWithFormat:@"select * from posts p INNER JOIN categories cat where p.sendStatus = 3 AND p.group_remote_key = 0 AND cat.tag = %@ AND cat.post_remote_key = p.remoteKey order by date desc, p.remoteKey desc limit %d", tag, kGLPNumberOfPosts];
        
        resultSet = [db executeQueryWithFormat:@"select * from posts p INNER JOIN categories cat where (p.date < %d AND p.remoteKey is null) OR (p.remoteKey is not null AND p.remoteKey < %d) AND p.group_remote_key = 0 AND p.pending = 0 AND cat.tag = %@ AND cat.post_remote_key = p.remoteKey order by p.date desc, p.remoteKey desc limit %d", post.date, post.remoteKey, tag, kGLPNumberOfPosts];
    }
    
    return resultSet;
}

+ (FMResultSet *)allPostsWaitingForApprovalWithDb:(FMDatabase *)db
{
    return [db executeQueryWithFormat:@"select * from posts where sendStatus = 3 AND group_remote_key = 0 AND pending = 1 order by date desc"];
}

+ (FMResultSet *)reviewHistoryWithPost:(GLPPost *)post andDb:(FMDatabase *)db
{
    return [db executeQueryWithFormat:@"select * from review_history where post_remote_key = %d AND action != 0 order by date desc", post.remoteKey];
}

@end
