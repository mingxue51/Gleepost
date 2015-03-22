//
//  GLPAttendingPostsManager.m
//  Gleepost
//
//  Created by Silouanos on 03/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This manager should have an instance in GLPAttendingPostsViewController in order
//  to make the data management.

#import "GLPAttendingPostsManager.h"
#import "GLPPostManager.h"
#import "AttendingPostsOrganiserHelper.h"
#import "GLPPostImageLoader.h"
#import "GLPPostNotificationHelper.h"

@interface GLPAttendingPostsManager ()

@property (assign, nonatomic) NSInteger userRemoteKey;
@property (strong, nonatomic) AttendingPostsOrganiserHelper *attendingPostsOrganiserHelper;
@property (strong, nonatomic) NSMutableArray *events;

@end

@implementation GLPAttendingPostsManager

- (id)initWithUserRemoteKey:(NSInteger)userRemoteKey
{
    self = [super init];
    if (self)
    {
        _userRemoteKey = userRemoteKey;
        [self initialiseObjects];
        [self loadInitialPosts];
    }
    return self;
}

#pragma mark - Configuration

- (void)initialiseObjects
{
    _attendingPostsOrganiserHelper = [[AttendingPostsOrganiserHelper alloc] init];
    _events = nil;
}

#pragma mark - Client

- (void)loadInitialPosts
{
    [GLPPostManager getAttendingEventsWithUsersRemoteKey:_userRemoteKey callback:^(BOOL success, NSArray *posts) {

        [_attendingPostsOrganiserHelper organisePosts:posts];
        
        _events = posts.mutableCopy;
        
        [[GLPPostImageLoader sharedInstance] addPostsImages:_events];

        [self notifyViewControllerWithPostsAndSuccess:success];
        
    }];
}

#pragma mark - Operations

- (void)getPosts
{
    if(_events)
    {
        [self notifyViewControllerWithPostsAndSuccess:YES];
    }
}

- (void)loadPreviousPosts
{
    DDLogDebug(@"GLPAttendingPostsManager : loadPreviousPosts last post %@", [_attendingPostsOrganiserHelper lastPost]);
    
    [GLPPostManager getAttendingEventsAfter:[_events lastObject] withUserRemoteKey:_userRemoteKey callback:^(BOOL success, BOOL remain, NSArray *posts) {
        
        if(posts.count > 0)
        {
            [_attendingPostsOrganiserHelper organisePosts:posts];
            [_events insertObjects:posts atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_events.count, posts.count)]];
            [[GLPPostImageLoader sharedInstance] addPostsImages:_events];
            
        }
        
        if(!posts)
        {
            posts = [[NSMutableArray alloc] init];
        }
        
        [self notifyViewControllerWithPreviousPosts:posts withRemain:remain andSuccess:success];

    }];
}

/**
 Removes a post from the attending events' list and returns the index path of the removed
 post.
 
 @param post the post to be deleted.
 
 @return a dictionary contains post's index path with key: index_path and a boolean variable that 
        indicates if a sections needs to be deleted with key: delete_section.
 */
- (NSDictionary *)removePostWithPost:(GLPPost *)post
{
    [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey inCampusLive:NO];
    NSDictionary *indexPathDeletedSection = [_attendingPostsOrganiserHelper removePost:post];

    for(int index = 0; index < _events.count; ++index)
    {
        GLPPost *p = [_events objectAtIndex:index];
        
        if(p.remoteKey == post.remoteKey)
        {
            [_events removeObject:p];
            
            return indexPathDeletedSection;
        }
    }
    
    return indexPathDeletedSection;
}

- (NSIndexPath *)updatePostWithRemoteKey:(NSInteger)postRemoteKey andViewsCount:(NSInteger)viewsCount
{
    return [_attendingPostsOrganiserHelper updatePostWithRemoteKey:postRemoteKey andViewsCount:viewsCount];
}

#pragma mark - Accessors

- (NSInteger)eventsCount
{
    return _events.count;
}

- (NSInteger)numberOfSections
{
    return [_attendingPostsOrganiserHelper numberOfSections];
}

- (NSInteger)numberOfPostsAtSectionIndex:(NSInteger)index
{
    return [_attendingPostsOrganiserHelper postsAtSectionIndex:index].count;
}

- (GLPPost *)postWithSection:(NSInteger)section andIndex:(NSInteger)index
{
    return [_attendingPostsOrganiserHelper postWithIndex:index andSectionIndex:section];
}

- (NSString *)headerInSection:(NSInteger)sectionIndex
{
    return [_attendingPostsOrganiserHelper headerInSection:sectionIndex];
}

- (NSIndexPath *)indexPathWithPost:(GLPPost **)post
{
    return [_attendingPostsOrganiserHelper indexPathWithPost:*post];
}


#pragma mark - Post notifications

- (void)notifyViewControllerWithPostsAndSuccess:(BOOL)success
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_ATTENDING_POSTS_FETCHED object:self userInfo:@{@"success" : @(success)}];
}

- (void)notifyViewControllerWithPreviousPosts:(NSArray *)posts withRemain:(NSInteger)remain andSuccess:(BOOL)success
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_ATTENDING_PREVIOUS_POSTS_FETCHED object:self userInfo:@{@"success" : @(success), @"posts" : posts, @"remain" : @(remain)}];
}


@end
