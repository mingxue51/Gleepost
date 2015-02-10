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
#import "UserProfileManager.h"

@interface ProfileManager ()

@property (strong, nonatomic) GLPCampusWallAsyncProcessor *campusWallAsyncProcessor;
@property (assign, nonatomic) BOOL remoteLoadedFinished;

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
    _remoteLoadedFinished = NO;
}

#pragma mark - Client

- (void)loadInitialPosts
{
    [GLPPostManager loadPostsWithRemoteKey:_userRemoteKey localCallback:^(NSArray *posts) {
        
        if(posts.count > 0 && self.posts.count == 0)
        {
            self.remoteLoadedFinished = NO;
            [self setNewPosts:posts];
            [self sendNotificationWithPostsWithSuccess:YES];
        }
        
    } remoteCallback:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            [self setNewPosts:posts];
        }
        
        self.remoteLoadedFinished = YES;
        [self sendNotificationWithPostsWithSuccess:success];

        
    }];
}

- (void)reloadPosts
{
    [self loadInitialPosts];
}

- (void)setNewPosts:(NSArray *)newPosts
{
    _posts = [newPosts mutableCopy];
    
    if([self isKindOfClass:[UserProfileManager class]])
    {
        DDLogDebug(@"ProfileManager : set fake keys");
        
        [GLPPostManager setFakeKeysToPrivateProfilePosts:self.posts];
    }
    
    [[GLPPostImageLoader sharedInstance] addPostsImages:self.posts];
}

#pragma mark - Operations

- (void)getPosts
{
    if(_posts.count > 0)
    {
        [self sendNotificationWithPostsWithSuccess:YES];
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
    
    NSInteger index = [_campusWallAsyncProcessor findIndexFromPostsArray:_posts withPostRemoteKey:postRemoteKey];
    
    GLPPost *post = nil;
    
    if(index != -1)
    {
        post = [self.posts objectAtIndex:index];
        post.viewsCount = viewsCount;
    }
    else
    {
        callback(-1);
    }
    
    if([post isVideoPost])
    {
        callback(-1);
    }
    else
    {
        callback(index);
    }

}

#pragma mark - Post notifications

- (void)sendNotificationWithPostsWithSuccess:(BOOL)success
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[self postsNotificationName] object:self userInfo:@{@"success" : @(success), @"remote" : @(self.remoteLoadedFinished)}];
}

- (void)sendNotificationWithPreviousPosts:(NSArray *)previousPosts withRemain:(BOOL)remain andSuccess:(BOOL)success
{
    NSDictionary *userInfo = @{@"success" : @(success), @"remain" : @(remain), @"posts" : previousPosts};
    [[NSNotificationCenter defaultCenter] postNotificationName:[self previousPostsNotificationName] object:self userInfo:userInfo];
}

#pragma mark - Static

- (NSString *)postsNotificationName
{
    return [NSString stringWithFormat:@"%@_%d", GLPNOTIFICATION_USERS_POSTS_FETCHED, self.userRemoteKey];
}

- (NSString *)previousPostsNotificationName
{
    return [NSString stringWithFormat:@"%@_%d", GLPNOTIFICATION_USERS_PREVIOUS_POSTS_FETCHED, self.userRemoteKey];
}


@end
