//
//  GLPTrackViewsCountProcessor.m
//  Gleepost
//
//  Created by Silouanos on 23/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPTrackViewsCountProcessor.h"
#import "GLPPost.h"
#import "WebClientJSON.h"

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
    _currentPosts = visiblePosts.mutableCopy;
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
            //Send notification to cells.
            [[NSNotificationCenter defaultCenter] postNotificationName:[self generateNotificationForPost:post] object:self];
        }
    }];
}

- (NSString *)generateNotificationForPost:(GLPPost *)post
{
    return [NSString stringWithFormat:@"%@_%ld", GLPNOTIFICATION_POST_CELL_VIEWS_UPDATE, (long)post.remoteKey];
}

#pragma mark - Helpers

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
