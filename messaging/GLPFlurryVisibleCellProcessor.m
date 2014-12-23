//
//  GLPFlurryVisibleCellProcessor.m
//  Gleepost
//
//  Created by Silouanos on 07/04/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPFlurryVisibleCellProcessor.h"
#import "UIViewController+Flurry.h"
#import "Flurry.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface PostTime : NSObject

@property (strong, nonatomic) GLPPost *post;
@property (strong, nonatomic) NSDate *date;

@end

@implementation PostTime

-(id)initWithPost:(GLPPost *)post andTime:(NSDate *)date
{
    self = [super init];
    
    if(self)
    {
        _post = post;
        _date = date;
    }
    
    return self;
}

@end


@interface GLPFlurryVisibleCellProcessor ()

@property (strong, nonatomic) NSMutableDictionary *currentPosts;
@property (strong, nonatomic) NSMutableArray *currentPostsArray;

@end


@implementation GLPFlurryVisibleCellProcessor

const float VISIBILITY_TIME = 2.0f;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _currentPosts = [[NSMutableDictionary alloc] init];
        _currentPostsArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addVisiblePosts:(NSArray *)posts
{
    for(GLPPost *p in posts)
    {
        NSDate *timestamp = [NSDate date];
        
        PostTime *pt = [[PostTime alloc] initWithPost:p andTime:timestamp];
        
        if(![self isPostInArray:p])
        {
            [NSTimer scheduledTimerWithTimeInterval:VISIBILITY_TIME target:self selector:@selector(sendToFlurry:) userInfo:pt repeats:NO];
        }
    }
    _currentPostsArray = posts.mutableCopy;
}

/**
 Resets the array when the user continue scroll. So the visible cells are going to be dismissed.
 */
-(void)resetVisibleCells
{
    if(_currentPosts.count > 0)
    {
        [_currentPosts removeAllObjects];
    }
    
}

-(void)sendToFlurry:(NSTimer *)sender
{

    PostTime *postTime = sender.userInfo;
    
    
    if([self isPostInArray:postTime.post])
    {
        DDLogDebug(@"Send to flurry and google analytics: %d", postTime.post.remoteKey);
        [self sendFlurryAnalyticsWithPost:postTime.post];
        [self sendGAIAnalyticsWithPost:postTime.post];
    }

}

-(BOOL)isPostInArray:(GLPPost *)post
{
    for(GLPPost *p in _currentPostsArray)
    {
        if(post.remoteKey == p.remoteKey)
        {
            return YES;
        }
    }
    
    return NO;
}

-(void)sendFlurryAnalyticsWithPost:(GLPPost *)post
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", post.remoteKey], @"Key", nil];

    [Flurry logEvent:@"PostCell" withParameters:params];
}

-(void)sendGAIAnalyticsWithPost:(GLPPost *)post
{
    // Initialize tracker
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GLP_GAI_TRACK_ID];
    
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Visible Posts"     // Event category (required)
                                                          action:@"PostCell"  // Event action (required)
                                                           label:[NSString stringWithFormat:@"%d", post.remoteKey] // Event label
                                                           value:nil] build]];  // Event value
}

@end
