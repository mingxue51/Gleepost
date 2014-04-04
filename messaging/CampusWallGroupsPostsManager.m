//
//  CampusWallGroupsPostsManager.m
//  Gleepost
//
//  Created by Σιλουανός on 4/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusWallGroupsPostsManager.h"
#import "WebClient.h"
#import "GLPPostManager.h"
#import "GLPGroupManager.h"

@interface CampusWallGroupsPostsManager ()

@property (strong, nonatomic) NSMutableArray *posts;

@end

@implementation CampusWallGroupsPostsManager


static CampusWallGroupsPostsManager *instance = nil;

+(CampusWallGroupsPostsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[CampusWallGroupsPostsManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Initilisation

-(id)init
{
    self = [super init];
    
    if(self)
    {
        [self initialiseObjects];
    }
    
    return self;
}


-(void)initialiseObjects
{
    _posts = [[NSMutableArray alloc] init];
}

#pragma mark - Client

//-(void)getPostsGroupsFeedWithCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock
//{
//    [[WebClient sharedInstance] getPostsGroupsFeedWithCallbackBlock:^(BOOL success, NSArray *posts) {
//       
//        callbackBlock(YES, posts);
//        
//    }];
//}

#pragma mark - Modifiers

-(void)setPosts:(NSMutableArray *)posts
{
    _posts = posts;
    
    [GLPPostManager setFakeKeysToPrivateProfilePosts:_posts];
}


/**
 
 Returns all the new posts if new posts exist.
 
 @param posts all the posts from server.
 
 @return posts that are not exist in the current posts array.
 
 */
-(NSArray *)addNewPosts:(NSMutableArray *)recentPosts
{
    NSMutableArray *recent = [[NSMutableArray alloc] init];
    BOOL found = NO;
    
    //Find new posts.
    for(GLPPost *recentPost in recentPosts)
    {
        for(GLPPost *post in _posts)
        {
            if(recentPost.remoteKey == post.remoteKey)
            {
                found = YES;
                break;
            }
        }
        
        if(!found)
        {
            [recent addObject:recentPost];
        }
        
        found = NO;
    }
    
    [_posts replaceObjectsInRange:NSMakeRange(0,0) withObjectsFromArray:recent];
    DDLogDebug(@"Recent grou posts: %@", recent);
    
    return recent;
    
}

//NSInteger res = [_posts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//    
//    return ((GLPPost *)obj).remoteKey == post.remoteKey;
//    
//}];
//
//if(res == NSNotFound)
//{
//    //Add post to list.
//    [_posts setObject:post atIndexedSubscript:0];
//    [recentPosts addObject:post];
//    
//    DDLogDebug(@"New post: %@", post);
//}

#pragma mark - Accessors

-(GLPPost *)postAtIndex:(int)index
{
    return [_posts objectAtIndex:index];
}

-(NSArray *)allPosts
{
    return _posts;
}

-(BOOL)arePostsEmpty
{
    return (_posts.count == 0);
}

-(int)numberOfPosts
{
    return _posts.count;
}

-(BOOL)isTextPostExist
{
    for(GLPPost *p in _posts)
    {
        if(![p imagePost])
        {
            return YES;
        }
    }
    
    return NO;
}

-(void)removePostAtIndex:(int)index
{
    [_posts removeObjectAtIndex:index];
}

#pragma mark - Client

-(void)loadGroupPosts
{
    [GLPGroupManager loadGroupsFeedWithCallback:^(BOOL success, NSArray *posts) {
       
        [self setPosts:posts.mutableCopy];
        
    }];
}

@end
