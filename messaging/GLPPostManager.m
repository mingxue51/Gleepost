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

+ (void)loadPostsBefore:(GLPPost *)post callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
{
    NSLog(@"load posts before %d - %@", post.remoteKey, post.content);
    
    [[WebClient sharedInstance] getPostsAfter:nil callback:^(BOOL success, NSArray *posts) {
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
            
            [newPosts addObject:newPost];
        }
        
        //[newPosts addObject:post]; //[newPosts addObject:post]; [newPosts addObject:post]; // comment / uncomment for debug reasons
        
        NSLog(@"remote posts %d", newPosts.count);
        
        if(!newPosts || newPosts.count == 0) {
            callback(YES, NO, nil);
            return;
        }
        
        // only new posts loaded, means it may remain some
        BOOL remain = newPosts.count == posts.count;
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            for (GLPPost *newPost in newPosts) {
                [GLPPostDao save:newPost inDb:db];
            }
        }];
        
        callback(YES, remain, newPosts);
    }];
}

+ (void)loadPostsAfter:(GLPPost *)post callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback
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
    
    [[WebClient sharedInstance] getPostsAfter:post callback:^(BOOL success, NSArray *posts) {
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
    [[WebClient sharedInstance] getPostsAfter:nil callback:^(BOOL success, NSArray *posts) {
        
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
        
        [[WebClient sharedInstance] getPostsAfter:nil callback:^(BOOL success, NSArray *posts) {
            
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

@end
