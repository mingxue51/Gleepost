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
#import "GLPTriggeredLabelTrackViewsConnector.h"

@interface GLPTrackViewsCountProcessor ()

/** Holds the last recorded posts */
@property (strong, nonatomic) NSMutableArray *currentPosts;

/** Holds the last recorded posts before user scrolls again. */
@property (strong, nonatomic) NSMutableDictionary *currentPostsDictionary;

/** Holds all the tracked posts (sent to the server). Cleared when the CampusWall view disappear. */
@property (strong, nonatomic) NSMutableSet *sentPosts;

/** Holds all the posts' Y values. */
@property (strong, nonatomic) NSMutableArray *currentPostsYValues;

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
        _currentPostsYValues = [[NSMutableArray alloc] init];
        _sentPosts = [[NSMutableSet alloc] init];
        _visibilityTime = 2.0;
    }
    return self;
}

- (void)trackVisiblePosts:(NSArray *)visiblePosts
{
    
}

- (void)trackVisiblePosts:(NSArray *)visiblePosts withPostsYValues:(NSArray *)visiblePostsYValues
{
    
//    if([visiblePosts isEqualToArray:_currentPosts])
//    {
//        DDLogDebug(@"Array duplication ABORT!");
//        
//        return;
//    }
    //        if(![_sentPosts containsObject:@(p.remoteKey)] && p.remoteKey == [[GLPTriggeredLabelTrackViewsConnector sharedInstance] currentPostRemoteKey])

    //        if([[GLPTriggeredLabelTrackViewsConnector sharedInstance] currentPostRemoteKey] == p.remoteKey)

    
    for(int i = 0; i < visiblePosts.count; ++i)
    {
        GLPPost *p = [visiblePosts objectAtIndex:i];
        float postY = [[visiblePostsYValues objectAtIndex:i] floatValue];
        
        [_currentPostsDictionary setObject:p forKey:@(p.remoteKey)];
        
        if([self post:p withYValue:postY])
        {
            [NSTimer scheduledTimerWithTimeInterval:_visibilityTime target:self selector:@selector(trackPost:) userInfo:p repeats:NO];
        }
    }
    
    if(_currentPosts.count > 0)
    {
        NSMutableArray *unsubscribeArray = _currentPosts.copy;
        
        [unsubscribeArray.mutableCopy removeObjectsInArray:visiblePosts];
        
        [self unsubscribePosts:unsubscribeArray];
    }
    _currentPosts = visiblePosts.mutableCopy;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(subscribePosts:) userInfo:visiblePosts repeats:NO];
}

/**
 Decides if the input post (passed as a parameter) should be tracked depending on
 the kind of post and on its Y value on the table view.
 For example, a text post should be marked as "read", from user, in wider range
 from video post that is bigger cell.
 
 @param post the under consideration post.
 @param yValue the Y value of actual cell on the table view.
 
 @return returns YES if the post should be considered as "read",
 otherwise NO.
 */
- (BOOL)post:(GLPPost *)post withYValue:(float)yValue
{
    DDLogDebug(@"GLPTrackViewsCountProcessor : post %@ y value %f", post.content, yValue);
    
    if([post isVideoPost])
    {
        if(yValue >= 0.0 && yValue <= 80.0)
        {
            DDLogDebug(@"Track video post %@", post.content);
            return YES;
        }
    }
    else if([post imagePost])
    {
        if(yValue >= 40.0 && yValue <= 160.0)
        {
            DDLogDebug(@"Track image post %@", post.content);
            return YES;
        }
    }
    else
    {
        if(yValue >= 50.0 && yValue <= 320)
        {
            DDLogDebug(@"Track text post %@", post.content);
            return YES;
        }
        //50 - 320
    }
    
    return NO;
}

- (void)trackPost:(NSTimer *)timer
{
    GLPPost *post = timer.userInfo;
    
    if([self isPostInArray:post])
    {
        [self increaseViewsCountWithPost:post];
    }
}

#pragma mark - Mofifiers

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

- (void)resetSentPostsSet
{
    DDLogDebug(@"Reset sent SET %@", _sentPosts);
    
    [self unsubscribePosts:_sentPosts];
    
    [_sentPosts removeAllObjects];
    
    [[GLPTriggeredLabelTrackViewsConnector sharedInstance] reset];
}

#pragma mark - Client

- (void)increaseViewsCountWithPost:(GLPPost *)post
{
    if(![_currentPostsDictionary objectForKey:@(post.remoteKey)])
    {
        DDLogDebug(@"GLPTrackViewsCountProcessor : Post not in! %@", post.content);
        return;
    }
    
    DDLogInfo(@"GLPTrackViewsCountProcessor : post viewed %@", post.content);
    
    [[WebClientJSON sharedInstance] visibleViewsWithPosts:@[post] withCallbackBlock:^(BOOL success) {
        
        if(success)
        {
            //Add sent post to the NSMutableSet.
            [_sentPosts addObject:@(post.remoteKey)];
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
- (void)unsubscribePosts:(id)unsbuscribePosts
{
    NSData *data = [self generatePostsData:unsbuscribePosts withSubscribe:NO];
    
    if(!data)
    {
        return;
    }
    
    [[GLPWebSocketClient sharedInstance] sendMessageWithJson:data];
}

/**
 This method subscribes posts. Should be called after reassigning the current posts array.
 */
- (void)subscribePosts:(NSTimer *)timer
{
    NSArray *newVisiblePosts = timer.userInfo;

    if(!newVisiblePosts)
    {
        return;
    }
    
    NSData *data = [self generatePostsData:newVisiblePosts withSubscribe:YES];
    
    if(!data)
    {
        return;
    }
    
    [[GLPWebSocketClient sharedInstance] sendMessageWithJson:data];
}

#pragma mark - Helpers

/**
 Generates the data to be sent through the web socket, subscribe or unsubscribe.
 
 @param subscribe if YES then generates data for subcription posts if NO to unsubscribe posts.
 
 @return the data to be sent through the web socket.
 
 */
- (NSData *)generatePostsData:(id)posts withSubscribe:(BOOL)subscribe
{
    //{"action":"SUBSCRIBE", "posts":[123,456,789]}
    
    NSMutableArray *postsRemoteKeys = [[NSMutableArray alloc] init];
    
    if([posts isKindOfClass:[NSArray class]])
    {
        for(GLPPost *p in posts)
        {
            [postsRemoteKeys addObject:@(p.remoteKey)];
        }
    }
    else if ([posts isKindOfClass:[NSSet class]])
    {
        postsRemoteKeys = [(NSSet *)[posts allObjects] mutableCopy];
    }
    
    
    if(postsRemoteKeys.count == 0)
    {
        return nil;
    }

    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(subscribe) ? @"SUBSCRIBE" : @"UNSUBSCRIBE", @"action", postsRemoteKeys, @"posts", nil];

    DDLogDebug(@"GLPTrackViewsCountProcessor : generatePostsDataWithSubscribe %@", dataDictionary);
    
    return [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:nil];
}

//TODO: Not used.
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
