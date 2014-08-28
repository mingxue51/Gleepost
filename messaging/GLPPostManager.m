//
//  GLPPostManager.m
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPostManager.h"
#import "DatabaseManager.h"
#import "WebClient.h"
#import "GLPPost.h"
#import "GLPPostDao.h"
#import "SessionManager.h"

@implementation GLPPostManager

//NSInteger const kGLPNumberOfPosts = 20;

// load only local earlier posts
+ (void)loadLocalPostsBefore:(GLPPost *)post callback:(void (^)(NSArray *posts))callback
{
    NSLog(@"load local posts before %d - %@", post.remoteKey, post.content);
    
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPPostDao findAllPostsBefore:post inDb:db];
    }];
    
    NSLog(@"local posts %d", localEntities.count);
    callback(localEntities);
}

+(void)loadRemotePostsForUserRemoteKey:(int)remoteKey callback:(void (^)(BOOL success, NSArray *posts))callback
{
    [[WebClient sharedInstance] getPostsAfter:nil withCategoryTag:nil callback:^(BOOL success, NSArray *posts) {
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        
        //Find all the event posts that the user attends.
        [GLPPostManager addAttendingToEventPosts:posts callback:^(BOOL success, NSArray *posts) {
            
            if(!success) {
                callback(NO, nil);
                return;
            }
            
            
            // take only new posts
            NSMutableArray *userPosts = [NSMutableArray array];
            
            for (GLPPost *newPost in posts)
            {
                if(newPost.author.remoteKey == remoteKey)
                {
                    [userPosts addObject:newPost];
                }
                
            }
            
            callback(YES, userPosts);
        }];

    }];
}

+ (void)loadRemotePostsBefore:(GLPPost *)post withNotUploadedPosts:(NSArray*)notUploadedPosts andCurrentPosts:(NSArray*)posts callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
{
    NSLog(@"load posts before %d - %@", post.remoteKey, post.content);
    
    [[WebClient sharedInstance] getPostsAfter:nil withCategoryTag:[SessionManager sharedInstance].currentCategory.tag callback:^(BOOL success, NSArray *posts) {
        if(!success) {
            callback(NO, NO, nil);
            return;
        }
        
        
        //Find all the event posts that the user attends.
        [GLPPostManager addAttendingToEventPosts:posts callback:^(BOOL success, NSArray *posts) {
           
            if(!success) {
                callback(NO, NO, nil);
                return;
            }
            
            // take only new posts
            NSMutableArray *newPosts = [NSMutableArray array];
            for (GLPPost *newPost in posts) {
                
                if(newPost.remoteKey == post.remoteKey) {
                    
                    break;
                }
                
                
                if([GLPPostManager isPost:newPost containedInArray:notUploadedPosts])
                {
                    continue;
                }
                
                //If newPost is contained to already posted posts then continue.
                //Avoid duplications.
                //            if([GLPPostManager isPost:newPost containedInArray:posts])
                //            {
                //                continue;
                //            }
                
                
                
                [newPosts addObject:newPost];
            }
            
            //[newPosts addObject:post]; //[newPosts addObject:post]; [newPosts addObject:post]; // comment / uncomment for debug reasons
            
            DDLogInfo(@"remote posts %d", newPosts.count);
            
            if(!newPosts || newPosts.count == 0) {
                callback(YES, NO, nil);
                return;
            }
            
            // only new posts loaded, means it may remain some
            BOOL remain = newPosts.count == posts.count;
            
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                for (GLPPost *newPost in newPosts) {
                    newPost.sendStatus = kSendStatusSent;
                    [GLPPostDao save:newPost inDb:db];
                }
            }];
            
            callback(YES, remain, newPosts);
            
            
        }];
        
        
        
//        // take only new posts
//        NSMutableArray *newPosts = [NSMutableArray array];
//        for (GLPPost *newPost in posts) {
//            
//            if(newPost.remoteKey == post.remoteKey) {
//                break;
//            }
//            
//            if([GLPPostManager isPost:newPost containedInArray:notUploadedPosts])
//            {
//                continue;
//            }
//            
//            //If newPost is contained to already posted posts then continue.
//            //Avoid duplications.
////            if([GLPPostManager isPost:newPost containedInArray:posts])
////            {
////                continue;
////            }
//            
//
//            
//            [newPosts addObject:newPost];
//        }
//        
//        //[newPosts addObject:post]; //[newPosts addObject:post]; [newPosts addObject:post]; // comment / uncomment for debug reasons
//        
//        NSLog(@"remote posts %d", newPosts.count);
//        
//        if(!newPosts || newPosts.count == 0) {
//            callback(YES, NO, nil);
//            return;
//        }
//        
//        // only new posts loaded, means it may remain some
//        BOOL remain = newPosts.count == posts.count;
//        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            for (GLPPost *newPost in newPosts) {
//                [GLPPostDao save:newPost inDb:db];
//            }
//        }];
//        
//        callback(YES, remain, newPosts);
    }];
}

+(NSArray *)removeLastPost:(NSArray *)posts
{
    NSMutableArray *m = [[NSMutableArray alloc] initWithArray:posts];
    
    [m removeObjectAtIndex:0];
    
    return m.mutableCopy;
}

+(BOOL)isPost:(GLPPost*)post containedInArray:(NSArray*)posts
{
    for(GLPPost *p in posts)
    {
        if([p.content isEqualToString:post.content])
        {
            return YES;
        }
    }

    
    return NO;
}


+ (void)loadInitialPostsWithLocalCallback:(void (^)(NSArray *localPosts))localCallback remoteCallback:(void (^)(BOOL success, BOOL remain, NSArray *remotePosts))remoteCallback
{
    NSLog(@"load initial posts");
    
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPPostDao findLastPostsInDb:db];
    }];
    
    NSLog(@"local posts %d", localEntities.count);
    
    if(localEntities.count > 0) {
        localCallback(localEntities);
    }
    
    [[WebClient sharedInstance] getPostsAfter:nil withCategoryTag:[SessionManager sharedInstance].currentCategory.tag callback:^(BOOL success, NSArray *posts) {
        if(!success) {
            remoteCallback(NO, NO, nil);
            return;
        }
    
        
        NSLog(@"remote posts %d", posts.count);
        
        if(!posts || posts.count == 0) {
            remoteCallback(YES, NO, nil);
            return;
        }
        
        
        //Find all the event posts that the user attends.
        [GLPPostManager addAttendingToEventPosts:posts callback:^(BOOL success, NSArray *posts) {
            
            
            if(!success)
            {
                remoteCallback(NO, NO, nil);
                return;
            }
            
            
            
            
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                
                // clean posts table
//                [GLPPostDao deleteAllInDb:db];
                
                //Set liked to the database if the user liked from other device (?)
                for(GLPPost *post in posts)
                {
                    post.sendStatus = kSendStatusSent;
                    [GLPPostDao save:post inDb:db];
                }
            }];
            
            BOOL remains = posts.count == kGLPNumberOfPosts ? YES : NO;
            
            remoteCallback(YES, remains, posts);
            
            
        }];
        
        
        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            
//            // get list of posts with liked=YES
////            NSArray* likedPosts = [GLPPostDao likedPostsInDb:db];
//            
//            // clean posts table
//            [GLPPostDao deleteAllInDb:db];
//            
//            //Set liked to the database if the user liked from other device (?)
//            for(GLPPost *post in posts)
//            {
////                NSInteger res = [likedPosts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
////                    
////                    return ((GLPPost *)obj).remoteKey == post.remoteKey;
////                    
////                }];
////                
////                if(res != NSNotFound) {
////                    post.liked = YES;
////                }
//                
//                [GLPPostDao save:post inDb:db];
//            }
//        }];
//        
//        BOOL remains = posts.count == kGLPNumberOfPosts ? YES : NO;
//        
//        remoteCallback(YES, remains, posts);
    }];
}

+ (void)loadPreviousPostsAfter:(GLPPost *)post callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
{
    NSLog(@"load posts after %d - %@", post.remoteKey, post.content);
    
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = post ? [GLPPostDao findLastPostsAfter:post inDb:db] : [GLPPostDao findLastPostsInDb:db];
    }];
    
    NSLog(@"local posts %d", localEntities.count);
    
    if(localEntities.count > 0) {
        // delay for infime ms because fuck ios development
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            callback(YES, YES, localEntities);
        });

        return;
    }
    
    [[WebClient sharedInstance] getPostsAfter:post withCategoryTag:[SessionManager sharedInstance].currentCategory.tag callback:^(BOOL success, NSArray *posts) {
        if(!success) {
            callback(NO, NO, nil);
            return;
        }
        
        
        //Find all the event posts that the user attends.
        [GLPPostManager addAttendingToEventPosts:posts callback:^(BOOL success, NSArray *posts) {
           
            if(!success)
            {
                callback(NO, NO, nil);
            }
            
            NSLog(@"remote posts %d", posts.count);
            
            if(!posts || posts.count == 0) {
                callback(YES, NO, nil);
                return;
            }
            
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                for(GLPPost *post in posts) {
                    post.sendStatus = kSendStatusSent;
                    [GLPPostDao save:post inDb:db];
                }
            }];
            
            BOOL remains = posts.count == kGLPNumberOfPosts ? YES : NO;
            
            callback(YES, remains, posts);
            
            
        }];
        
//        NSLog(@"remote posts %d", posts.count);
//        
//        if(!posts || posts.count == 0) {
//            callback(YES, NO, nil);
//            return;
//        }
//        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            for(GLPPost *post in posts) {
//                [GLPPostDao save:post inDb:db];
//            }
//        }];
//        
//        BOOL remains = posts.count == kGLPNumberOfPosts ? YES : NO;
//        
//        callback(YES, remains, posts);
    }];
}

+(void)loadPostWithRemoteKey:(NSInteger)remoteKey callback:(void (^)(BOOL sucess, GLPPost* post))callback
{
    [[WebClient sharedInstance] getPostWithRemoteKey:remoteKey withCallbackBlock:^(BOOL success, GLPPost *post) {
       
        if(success)
        {
            DDLogInfo(@"Got post with content: %@ : %@", post.content, post.video);
            
            callback(success,post);
        }
        else
        {
            callback(NO, nil);
        }
        
    }];
}


+(void)loadEventsRemotePostsForUserRemoteKey:(int)remoteKey callback:(void (^)(BOOL success, NSArray *posts))callback
{
    [[WebClient sharedInstance] getPostsAfter:nil withCategoryTag:nil callback:^(BOOL success, NSArray *posts) {
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        // take only new posts
        NSMutableArray *eventPosts = [NSMutableArray array];
        
        for (GLPPost *newPost in posts)
        {
            [eventPosts addObject:newPost];
        }
        
        callback(YES, eventPosts);
    }];
}

+(void)addAttendingToEventPosts:(NSArray *)posts callback:(void (^) (BOOL success, NSArray* posts))callback
{
    [[WebClient sharedInstance] userAttendingLivePostsWithCallbackBlock:^(BOOL success, NSArray *postsIds) {
       
        if(success)
        {
            [GLPPostManager formatEventPosts:posts withPostIds:postsIds];
            
            callback(YES, posts);
        }
        else
        {
            callback(NO, nil);
        }
        
    }];
}

+(void)formatEventPosts:(NSArray *)posts withPostIds:(NSArray *)postsIds
{
    for(GLPPost *p in posts)
    {
        for(NSNumber *n in postsIds)
        {
            if([n integerValue] == p.remoteKey)
            {
                p.attended = YES;
            }
        }
    }
}

//+(void)getNewPostsAndSaveToDatabaseWithOldPosts:(NSArray*)localEntities
//{
//    [[WebClient sharedInstance] getPostsAfter:nil callback:^(BOOL success, NSArray *posts) {
//        
//        NSArray *newEntities = [[NSArray alloc] init];
//        
//        if(success)
//        {
//            //Find and add only new posts from server.
//            newEntities = [GLPPostManager findAndAddServerPosts:posts withLocalPosts:localEntities];
//            
//            NSLog(@"New entities: %@",newEntities);
//        }
//        
//    }];
//}


//+(void)loadNewPostsWithCallback:(void (^) (BOOL success, NSArray*posts))callback
//{
//    __block NSArray *localEntities = nil;
//    
//    
//    
//    [DatabaseManager run:^(FMDatabase *db) {
//        localEntities = [GLPPostDao findLastPostsInDb:db];
//        
//        [[WebClient sharedInstance] getPostsAfter:nil callback:^(BOOL success, NSArray *posts) {
//            
//            if(success)
//            {
//                if([[posts objectAtIndex:0] remoteKey] != [[localEntities objectAtIndex:0] remoteKey])
//                {
//                    //Find and add only new posts from server.
//                    localEntities = [GLPPostManager findAndAddServerPosts:posts withLocalPosts:localEntities];
//                    
//                   // localEntities = posts;
//                    
//                    //Save in database new posts.
//                    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//                        
//                        for(GLPPost *post in localEntities)
//                        {
//                            [GLPPostDao save:post inDb:db];
//                        }
//                    }];
//                    
//                    callback(YES, localEntities);
//                    
//                }
//                else
//                {
//                    if(localEntities.count > 0) {
//                        callback(YES, localEntities);
//                        return;
//                    }
//                }
//            }
//            else
//            {
//                callback(NO, nil);
//                return;
//            }
//            
//        }];
//    }];
//
//}
//
//+(NSArray*)findAndAddServerPosts:(NSArray*)serverPosts withLocalPosts:(NSArray*)localPosts
//{
//    int lastOldPost = 0;
//    NSMutableArray *lastPosts = [[NSMutableArray alloc] init];
//    
//    for(int i = serverPosts.count-1; i>=0; --i)
//    {
//        if([[serverPosts objectAtIndex:i] remoteKey] != [[localPosts objectAtIndex:i] remoteKey])
//        {
//            ++lastOldPost;
//        }
//        else
//        {
//            break;
//        }
//    }
//    
//    for(int i = 0; i<lastOldPost; ++i)
//    {
//        [lastPosts addObject:[serverPosts objectAtIndex:i]];
//    }
//    
//    return lastPosts;
//}

//+ (void)loadPostsWithCallback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
//{
//    __block NSArray *localEntities = nil;
//    
//    
//    
//    [DatabaseManager run:^(FMDatabase *db) {
//        localEntities = [GLPPostDao findLastPostsInDb:db];
//        
//        [[WebClient sharedInstance] getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
//
//            if(success)
//            {
//               if([[posts objectAtIndex:0] remoteKey] != [[localEntities objectAtIndex:0] remoteKey])
//               {
//                   localEntities = posts;
//                   
//                   //Save in database new posts.
//                   [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//                       
//                       for(GLPPost *post in posts)
//                       {
//                           [GLPPostDao save:post inDb:db];
//                       }
//                   }];
//                   
//                   callback(YES, YES, localEntities);
//
//               }
//                else
//                {
//                    if(localEntities.count > 0) {
//                        callback(YES, YES, localEntities);
//                        return;
//                    }
//                }
//            }
//            else
//            {
//                callback(NO, NO, nil);
//                return;
//            }
//            
//        }];
//    }];
//}


/**
 
 
 */
+ (void)searchForPendingVideoPostCallback:(void (^) (NSArray *videoPosts))callback
{
    __block NSArray *incomingPosts;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        incomingPosts = [GLPPostDao findAllPendingPostsWithVideosInDb:db];
        
        callback(incomingPosts);
        
    }];
}

+(void)createLocalPost:(GLPPost *)post
{
    post.sendStatus = kSendStatusLocal;
    post.date = [NSDate date];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPPostDao save:post inDb:db];
    }];
}

+(void)updatePostWithRemoteKey:(int)remoteKey andNumberOfComments:(int)numberOfComments
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPPostDao updateCommentStatusWithNumberOfComments:numberOfComments andPostRemoteKey:remoteKey inDb:db];
    }];
}

+(void)updatePostWithLiked:(GLPPost*)post
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPPostDao updateLikedStatusWithPost:post inDb:db];
    }];
}

+(void)updatePostAttending:(GLPPost*)post
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPPostDao updatePostAttending:post db:db];
    }];
}

+(void)deletePostWithPost:(GLPPost *)post
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPPostDao deletePostWithPost:post db:db];
    }];
}


// update local post to either sent or error
+ (void)updatePostAfterSending:(GLPPost *)post
{
    DDLogInfo(@"Update post after sending: %@", post);
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPPostDao updatePostSendingData:post inDb:db];
    }];
}

+ (void)updateVideoPostAfterSending:(GLPPost *)videoPost
{
    DDLogInfo(@"Update video post after sending: %@", videoPost);
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPPostDao updateVideoPostSendingData:videoPost inDb:db];
    }];

}

+ (void)updateVideoPostBeforeSending:(GLPPost *)videoPost
{
    DDLogInfo(@"Update video post before sending: %@", videoPost);
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPPostDao updateVideoPostSendingData:videoPost inDb:db];
    }];
}

/**
 Temporary method to set "virtual keys" to posts in order to create the possibility
 of adding comment asynchronously on those posts too.
 
 @param privateProfilePosts Particular user's posts.
 
 */
+ (void)setFakeKeysToPrivateProfilePosts:(NSArray *)privateProfilePosts
{
    __block int lastPostIndex = 0;
    NSMutableArray *profilePosts = privateProfilePosts.mutableCopy;
    
    //Take the last key of the current campus wall posts from database.
    [GLPPostManager loadLocalPostsBefore:nil callback:^(NSArray *posts) {
       
        if(posts.count != 0)
        {
            GLPPost *lastPost = [posts objectAtIndex:posts.count-1];
            lastPostIndex = lastPost.key;
        }


    }];
    
    
    for(GLPPost *post in profilePosts)
    {
        ++lastPostIndex;
        
        post.key = lastPostIndex;
    }
}

+ (GLPPost *)setFakeKeyToPost:(GLPPost *)post
{
    __block int lastPostIndex = 0;
    
    //Take the last key of the current campus wall posts from database.
    [GLPPostManager loadLocalPostsBefore:nil callback:^(NSArray *posts) {
        
        if(posts.count != 0)
        {
            GLPPost *lastPost = [posts objectAtIndex:posts.count-1];
            lastPostIndex = lastPost.key;
        }

        
    }];
    
    post.key = lastPostIndex+1;
    
    return post;
}

@end
