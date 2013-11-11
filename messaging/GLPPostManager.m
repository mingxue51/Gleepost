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

@implementation GLPPostManager

NSInteger const kGLPNumberOfPosts = 20;

+ (void)loadPostsWithCallback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
{
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPPostDao findLastPostsInDb:db];
    }];
    
    NSLog(@"local posts %d", localEntities.count);
    
    if(localEntities.count > 0)
    {
        //Call to get new posts from server.

        
        //[GLPPostManager getNewPostsAndSaveToDatabaseWithOldPosts:localEntities];
        
        
        
        
        
        callback(YES, YES, localEntities);
        return;

    }
    
    [[WebClient sharedInstance] getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
        if(!success) {
            callback(NO, NO, nil);
            return;
        }
        
        NSLog(@"remote posts %d", posts.count);
        
        if(!posts || posts.count == 0) {
            callback(YES, NO, nil);
            return;
        }
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            for(GLPPost *post in posts) {
                [GLPPostDao save:post inDb:db];
            }
        }];
        
        BOOL remains = posts.count == kGLPNumberOfPosts ? YES : NO;
        
        callback(YES, remains, posts);
    }];
}

+(void)getNewPostsAndSaveToDatabaseWithOldPosts:(NSArray*)localEntities
{
    [[WebClient sharedInstance] getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
        
        NSArray *newEntities = [[NSArray alloc] init];
        
        if(success)
        {
            //Find and add only new posts from server.
            newEntities = [GLPPostManager findAndAddServerPosts:posts withLocalPosts:localEntities];
            
            NSLog(@"New entities: %@",newEntities);
        }
        
    }];
}


+(void)loadNewPostsWithCallback:(void (^) (BOOL success, NSArray*posts))callback
{
    __block NSArray *localEntities = nil;
    
    
    
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPPostDao findLastPostsInDb:db];
        
        [[WebClient sharedInstance] getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
            
            if(success)
            {
                if([[posts objectAtIndex:0] remoteKey] != [[localEntities objectAtIndex:0] remoteKey])
                {
                    //Find and add only new posts from server.
                    localEntities = [GLPPostManager findAndAddServerPosts:posts withLocalPosts:localEntities];
                    
                   // localEntities = posts;
                    
                    //Save in database new posts.
                    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                        
                        for(GLPPost *post in localEntities)
                        {
                            [GLPPostDao save:post inDb:db];
                        }
                    }];
                    
                    callback(YES, localEntities);
                    
                }
                else
                {
                    if(localEntities.count > 0) {
                        callback(YES, localEntities);
                        return;
                    }
                }
            }
            else
            {
                callback(NO, nil);
                return;
            }
            
        }];
    }];

}

+(NSArray*)findAndAddServerPosts:(NSArray*)serverPosts withLocalPosts:(NSArray*)localPosts
{
    int lastOldPost = 0;
    NSMutableArray *lastPosts = [[NSMutableArray alloc] init];
    
    for(int i = serverPosts.count-1; i>=0; --i)
    {
        if([[serverPosts objectAtIndex:i] remoteKey] != [[localPosts objectAtIndex:i] remoteKey])
        {
            ++lastOldPost;
        }
        else
        {
            break;
        }
    }
    
    for(int i = 0; i<lastOldPost; ++i)
    {
        [lastPosts addObject:[serverPosts objectAtIndex:i]];
    }
    
    return lastPosts;
}

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


+(void)saveNewPost:(GLPPost*)post
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
       
        [GLPPostDao save:post inDb:db];
       
    }];
}

+ (void)loadPostsAfter:(GLPPost *)post callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
{
    NSLog(@"load posts before %d - %@", post.key, post.content);
    
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPPostDao findLastPostsBefore:post inDb:db];
    }];
    
    NSLog(@"local posts %d", localEntities.count);
    
    if(localEntities.count > 0) {
        callback(YES, YES, localEntities);
        return;
    }
    
    [[WebClient sharedInstance] getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
        if(!success) {
            callback(NO, NO, nil);
            return;
        }
        
        
        
    }];
}

@end
