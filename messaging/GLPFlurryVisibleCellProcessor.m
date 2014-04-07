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
    
    
    ///    if ([date compare:beginDate] == NSOrderedAscending)
    
    if([self isPostInArray:postTime.post])
    {
        DDLogDebug(@"Send to flurry: %@", postTime.post.content);
        [self sendAnalyticsWithPost:postTime.post];
    }
    
    
//    if([_currentPosts objectForKey:[postInfo objectForKey:<#(id)#>]])
    
//    @synchronized(_currentPosts)
//    {
//        
//    }
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

-(void)sendAnalyticsWithPost:(GLPPost *)post
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", post.remoteKey], @"Key", nil];

    [Flurry logEvent:@"PostCell" withParameters:params];

}

@end
