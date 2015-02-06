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

@interface ProfileManager ()

@property (assign, nonatomic) NSInteger userRemoteKey;
@property (strong, nonatomic) NSMutableArray *posts;

@end

@implementation ProfileManager

- (id)initWithUsersRemoteKey:(NSInteger)userRemoteKey
{
    self = [super init];
    
    if(self)
    {
        _userRemoteKey = userRemoteKey;
        _posts = [[NSMutableArray alloc] init];
        [self loadInitialPosts];
    }
    
    return self;
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

#pragma mark - Post notifications

- (void)sendNotificationWithPostsAndSuccess:(BOOL)success
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[ProfileManager notificationNameWithUserRemoteKey:_userRemoteKey] object:self userInfo:@{@"success" : @(success)}];
}

- (void)sendNotificationWithPreviousPosts:(NSArray *)previousPosts withRemain:(BOOL)remain andSuccess:(BOOL)success
{
    
}

#pragma mark - Static

+ (NSString *)notificationNameWithUserRemoteKey:(NSInteger)userRemoteKey
{
    return [NSString stringWithFormat:@"%@_%d", GLPNOTIFICATION_USERS_POSTS_FETCHED, userRemoteKey];
}

@end
