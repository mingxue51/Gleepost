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
    
//    if(_currentPosts.count > 0)
//    {
//        [self unsubscribePosts:[self findPostsNeedUnsubscribeWithVisiblePosts:visiblePosts]];
//    }
    _currentPosts = visiblePosts.mutableCopy;
    [self subscribePosts:visiblePosts];
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

+ (void)updateViewsCounterOnPost:(GLPPost *)post
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[GLPTrackViewsCountProcessor generateNotificationForPost:post] object:self];
}

+ (NSString *)generateNotificationForPost:(GLPPost *)post
{
    return [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE, (long)post.remoteKey];
}

- (void)subscribePost:(GLPPost *)post
{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"SUBSCRIBE", @"action", @[@2091], @"posts", nil];
    
    DDLogDebug(@"subscribePost %@", d);
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:d options:NSJSONWritingPrettyPrinted error:nil];
    
    DDLogDebug(@"subscribePost data %@", data);

    [[GLPWebSocketClient sharedInstance] sendMessageWithJson:data];
}

/**
 This method unsubscribes the subscribed posts. Should be called before reassigning the current posts
 array.
 */
- (void)unsubscribePosts:(NSArray *)newVisiblePosts
{
    NSData *data = [self generatePostsDataWithSubscribe:NO];
    [[GLPWebSocketClient sharedInstance] sendMessageWithJson:data];
}

/**
 This method subscribes posts. Should be called after reassigning the current posts array.
 */
- (void)subscribePosts:(NSArray *)newVisiblePosts
{
    NSData *data = [self generatePostsDataWithSubscribe:YES];
    [[GLPWebSocketClient sharedInstance] sendMessageWithJson:data];
    
}

#pragma mark - Helpers

/**
 Generates the data to be sent through the web socket, subscribe or unsubscribe.
 
 @param subscribe if YES then generates data for subcription posts if NO to unsubscribe posts.
 
 @return the data to be sent through the web socket.
 
 */
- (NSData *)generatePostsDataWithSubscribe:(BOOL)subscribe
{
    //{"action":"SUBSCRIBE", "posts":[123,456,789]}
    
    NSMutableArray *postsRemoteKeys = [[NSMutableArray alloc] init];
    
    for(GLPPost *p in _currentPosts)
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

- (NSArray *)findPostsNeedSubscribeWithVisiblePosts:(NSArray *)visiblePosts
{
    
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
