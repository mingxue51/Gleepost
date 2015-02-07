//
//  ProfileManager.m
//  Gleepost
//
//  Created by Silouanos on 06/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Super class of LoggedInUserProfileManager and UserProfileManager.

#import "ProfileManager.h"
#import "GLPPostManager.h"
#import "GLPPostImageLoader.h"
#import "GLPPostNotificationHelper.h"
#import "GLPCampusWallAsyncProcessor.h"

@interface ProfileManager ()

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) GLPCampusWallAsyncProcessor *campusWallAsyncProcessor;

@end

@implementation ProfileManager

- (id)initWithUsersRemoteKey:(NSInteger)userRemoteKey
{
    self = [super init];
    
    if(self)
    {
        _userRemoteKey = userRemoteKey;
        [self loadInitialPosts];
        [self initialiseObjects];
    }
    
    return self;
}

- (void)initialiseObjects
{
    _campusWallAsyncProcessor = [[GLPCampusWallAsyncProcessor alloc] init];
    _posts = [[NSMutableArray alloc] init];
}

#pragma mark - Client

- (void)loadInitialPosts
{
    [GLPPostManager loadPostsWithRemoteKey:_userRemoteKey localCallback:^(NSArray *posts) {
        
        
    } remoteCallback:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            self.posts = [posts mutableCopy];
            [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];
            [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
        }
        
        [self sendNotificationWithPostsAndSuccess:success];

        
    }];
}

#pragma mark - Operations

- (void)getPosts
{
    if(_posts.count > 0)
    {
        [self sendNotificationWithPostsAndSuccess:YES];
    }
}

- (void)loadPreviousPosts
{
    [GLPPostManager loadPostsWithUsersRemoteKey:_userRemoteKey afterPost:[_posts lastObject] remoteCallback:^(BOOL success, BOOL remain, NSArray *posts) {
       
        if(success)
        {
            [self.posts insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.posts.count, posts.count)]];
            [[GLPPostImageLoader sharedInstance] addPostsImages:posts];
        }
        
        if(!posts)
        {
            posts = [[NSMutableArray alloc] init];
        }
        
        [self sendNotificationWithPreviousPosts:posts withRemain:remain andSuccess:success];
    }];
}


#pragma mark - Accessors

- (GLPPost *)postWithIndex:(NSInteger)index
{
    return _posts[index];
}

- (NSInteger)postsCount
{
    return _posts.count;
}

#pragma mark - Parsers

/**
 This method is used to parse ns notification when the cell needs to be refreshed.
 
 @param notification that contains RemoteKey in userInfo dictionary.
 
 @return the index of the post.
 
 */
- (NSInteger)parseRefreshCellNotification:(NSNotification *)notification
{
    return [GLPPostNotificationHelper parseRefreshCellNotification:notification withPostsArray:self.posts];
}

/**
 Parses ns notification with post remote key and returns (using callback) the index of the cell needs to be refreshed.
 This method also is responsible for updating a particular post when there is an updated views count.
 
 @param postRemoteKey
 @param notification that contains PostRemoteKey and UpdatedViewsCount keys in userInfo dictionary.
 
 */
- (void)parseAndUpdatedViewsCountPostWithNotification:(NSNotification *)notification withCallbackBlock:(void (^) (NSInteger index))callback
{
    NSInteger postRemoteKey = [notification.userInfo[@"PostRemoteKey"] integerValue];
    NSInteger viewsCount = [notification.userInfo[@"UpdatedViewsCount"] integerValue];
    
    [_campusWallAsyncProcessor parseAndUpdatedViewsCountPostWithPostRemoteKey:postRemoteKey andPosts:_posts withCallbackBlock:^(NSInteger index) {
                
        if(index != -1)
        {
            GLPPost *post = [self.posts objectAtIndex:index];
            post.viewsCount = viewsCount;
            
            if([post isVideoPost])
            {
                callback(-1);
            }
        }
        
        callback(index);
        
    }];
}

#pragma mark - Post notifications

- (void)sendNotificationWithPostsAndSuccess:(BOOL)success
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[ProfileManager postsNotificationNameWithUserRemoteKey:_userRemoteKey] object:self userInfo:@{@"success" : @(success)}];
}

- (void)sendNotificationWithPreviousPosts:(NSArray *)previousPosts withRemain:(BOOL)remain andSuccess:(BOOL)success
{
    NSDictionary *userInfo = @{@"success" : @(success), @"remain" : @(remain), @"posts" : previousPosts};
    [[NSNotificationCenter defaultCenter] postNotificationName:[ProfileManager previousPostsNotificationNameWithUserRemoteKey:_userRemoteKey] object:self userInfo:userInfo];
}

#pragma mark - Static

+ (NSString *)postsNotificationNameWithUserRemoteKey:(NSInteger)userRemoteKey
{
    return [NSString stringWithFormat:@"%@_%d", GLPNOTIFICATION_USERS_POSTS_FETCHED, userRemoteKey];
}

+ (NSString *)previousPostsNotificationNameWithUserRemoteKey:(NSInteger)userRemoteKey
{
    return [NSString stringWithFormat:@"%@_%d", GLPNOTIFICATION_USERS_PREVIOUS_POSTS_FETCHED, userRemoteKey];
}


@end
