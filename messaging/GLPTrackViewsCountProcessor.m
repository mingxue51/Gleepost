//
//  GLPTrackViewsCountProcessor.m
//  Gleepost
//
//  Created by Silouanos on 23/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  The methods that have to do with subscription and unsubscription (communication with web socket)
//  are used for tracking the views. 

#import "GLPTrackViewsCountProcessor.h"
#import "GLPPost.h"
#import "WebClientJSON.h"
#import "GLPWebSocketClient.h"

@interface GLPTrackViewsCountProcessor ()

/** Holds the last recorded posts */
@property (strong, nonatomic) NSMutableArray *currentPosts;

/** Holds the last recorded posts before user scrolls again */
@property (strong, nonatomic) NSMutableDictionary *currentPostsDictionary;

@property (assign, nonatomic) float visibilityTime;

@end

@implementation GLPTrackViewsCountProcessor

- (id)init
{
    self = [super init];
    if (self)
    {
        _currentPosts = [[NSMutableArray alloc] init];
        _currentPostsDictionary = [[NSMutableDictionary alloc] init];
        _visibilityTime = 2.0;
    }
    return self;
}

- (void)trackVisiblePosts:(NSArray *)visiblePosts
{
    for(GLPPost *p in visiblePosts)
    {
        [_currentPostsDictionary setObject:p forKey:@(p.remoteKey)];

        if(![self isPostInArray:p])
        {
            [NSTimer scheduledTimerWithTimeInterval:_visibilityTime target:self selector:@selector(trackPost:) userInfo:p repeats:NO];
        }
    }
    
    if(_currentPosts.count > 0)
    {
        NSMutableArray *unsubscribeArray = _currentPosts.copy;
        
        [unsubscribeArray.mutableCopy removeObjectsInArray:visiblePosts];
        
//        DDLogDebug(@"Current posts %@, Visible %@ UNSUBSCRIBE %@", unsubscribeArray, visiblePosts, unsubscribeArray);
        
//        [self unsubscribePosts:unsubscribeArray];
        
        
//        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(unsubscribePosts:) userInfo:unsubscribeArray repeats:NO];

    }
    _currentPosts = visiblePosts.mutableCopy;
    
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(subscribePosts:) userInfo:visiblePosts repeats:NO];

//    [self subscribePosts:visiblePosts];
}

- (void)resetVisibleCells
{
    if(_currentPostsDictionary.count > 0)
    {
        @synchronized(_currentPostsDictionary)
        {
            [_currentPostsDictionary removeAllObjects];
        }
    }
}

- (void)trackPost:(NSTimer *)timer
{
    GLPPost *post = timer.userInfo;
    
    if([self isPostInArray:post])
    {
        DDLogDebug(@"GLPTrackViewsCountProcessor : track posts");
        [self increaseViewsCountWithPost:post];
    }
}

#pragma mark - Client

- (void)increaseViewsCountWithPost:(GLPPost *)post
{
    if([_currentPostsDictionary objectForKey:@(post.remoteKey)])
    {
        DDLogDebug(@"GLPTrackViewsCountProcessor : Post in! %@", post.content);
    }
    else
    {
        DDLogDebug(@"GLPTrackViewsCountProcessor : Post not in! %@", post.content);
        
        return;
    }
    
    DDLogInfo(@"GLPTrackViewsCountProcessor : post viewed %@", post.content);
    
    [[WebClientJSON sharedInstance] visibleViewsWithPosts:@[post] withCallbackBlock:^(BOOL success) {
        
        if(success)
        {
            //We should not do anything!
        }
    }];
}

+ (void)updateViewsCounter:(NSInteger)updatedViewsCount onPost:(GLPPost *)post
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE object:self userInfo:@{@"UpdatedViewsCount": @(updatedViewsCount), @"PostRemoteKey" : @(post.remoteKey)}];
}

/**
 This method unsubscribes the subscribed posts. Should be called before reassigning the current posts
 array.
 */
- (void)unsubscribePosts:(NSArray *)unsbuscribePosts
{
//    NSArray *newVisiblePosts = timer.userInfo;
    
    NSData *data = [self generatePostsData:unsbuscribePosts withSubscribe:NO];
    [[GLPWebSocketClient sharedInstance] sendMessageWithJson:data];
}

/**
 This method subscribes posts. Should be called after reassigning the current posts array.
 */
- (void)subscribePosts:(NSTimer *)timer
{
    NSArray *newVisiblePosts = timer.userInfo;

    NSData *data = [self generatePostsData:newVisiblePosts withSubscribe:YES];
    [[GLPWebSocketClient sharedInstance] sendMessageWithJson:data];
}

#pragma mark - Helpers

/**
 Generates the data to be sent through the web socket, subscribe or unsubscribe.
 
 @param subscribe if YES then generates data for subcription posts if NO to unsubscribe posts.
 
 @return the data to be sent through the web socket.
 
 */
- (NSData *)generatePostsData:(NSArray *)posts withSubscribe:(BOOL)subscribe
{
    //{"action":"SUBSCRIBE", "posts":[123,456,789]}
    
    NSMutableArray *postsRemoteKeys = [[NSMutableArray alloc] init];
    
    for(GLPPost *p in posts)
    {
        [postsRemoteKeys addObject:@(p.remoteKey)];
    }
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(subscribe) ? @"SUBSCRIBE" : @"UNSUBSCRIBE", @"action", postsRemoteKeys, @"posts", nil];

    DDLogDebug(@"GLPTrackViewsCountProcessor : generatePostsDataWithSubscribe %@", dataDictionary);
    
    
    return [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSArray *)findPostsNeedUnsubscribeWithVisiblePosts:(NSArray *)visiblePosts
{
    NSMutableArray *postsToBeUnsubscribed = [[NSMutableArray alloc] init];
    
    for(GLPPost *cP in _currentPosts)
    {
        for(GLPPost *vP in visiblePosts)
        {
            if(cP.remoteKey == vP.remoteKey)
            {
                continue;
            }
        }
        
        [postsToBeUnsubscribed addObject:cP];
    }
    
    DDLogDebug(@"postsToBeUnsubscribed %@", postsToBeUnsubscribed);
    
    return postsToBeUnsubscribed;
    
    
}

-(BOOL)isPostInArray:(GLPPost *)post
{
    for(GLPPost *p in _currentPosts)
    {
        if(post.remoteKey == p.remoteKey)
        {
            return YES;
        }
    }
    return NO;
}

@end
