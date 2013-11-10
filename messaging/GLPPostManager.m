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
    
    if(localEntities.count > 0) {
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
