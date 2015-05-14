//
//  CampusLiveManager.m
//  Gleepost
//
//  Created by Silouanos on 11/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "CampusLiveManager.h"
#import "WebClient.h"
#import "DateFormatterHelper.h"
#import "GLPPostDao.h"

@interface CampusLiveManager ()

@property (strong, nonatomic) NSArray *liveEventPosts;

@end

@implementation CampusLiveManager

static CampusLiveManager *instance = nil;

+ (CampusLiveManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[CampusLiveManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Accessors

/**
 Informs the manager that the GLPCampusLiveViewController needs the posts.
 The manager loads posts and sends them to the GLPCampusLiveViewController (via NSNotification).
 */
- (void)getLiveEventPosts
{
    [self loadCurrentLivePostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
       
        if(success)
        {
            self.liveEventPosts = posts;
        }
        
        [self notifyCampusLiveForNewPostsWithStatus:success];
        
    }];
}

#pragma mark - Posts accessors

- (GLPPost *)eventPostAtIndex:(NSInteger)index
{
    return [self.liveEventPosts objectAtIndex:index];
}

- (NSInteger)eventsCount
{
    return self.liveEventPosts.count;
}

#pragma mark - Client

-(void)postLike:(BOOL)like withPostRemoteKey:(NSInteger)postRemoteKey
{
    [[WebClient sharedInstance] postLike:like forPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success) {
        
        if(success)
        {
            DDLogInfo(@"Like %d for post %ld succeed.",like, (long)postRemoteKey);
        }
        else
        {
            DDLogInfo(@"Like %d for post %ld not succeed.",like, (long)postRemoteKey);
        }
        
        
    }];
}

-(void)loadCurrentLivePostsWithCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock
{
    [[WebClient sharedInstance] getEventPostsAfterDate:[self currentTime] withCallbackBlock:^(BOOL success, NSArray *posts) {
        
        //TODO: remove that when is supported by the server.
        posts = [self filterPosts:posts];
        
        if(success)
        {
            [self savePostsInLocalDatabaseIfNotExist:posts];
            
            callbackBlock(YES, posts);
        }
        else
        {
            callbackBlock(NO, nil);
        }
        
    }];
}

- (void)savePostsInLocalDatabaseIfNotExist:(NSArray *)posts
{
    for(GLPPost *post in posts)
    {
        [GLPPostDao saveOrUpdatePost:post];
    }
}

-(void)formatLivePosts:(NSArray *)posts withPostIds:(NSArray *)postsIds
{
    for(GLPPost *p in posts)
    {
        for(NSNumber *n in postsIds)
        {
            if([n integerValue] == p.remoteKey)
            {
                p.attended = YES;
            }
        }
    }
}

-(void)loadRemotePosts:(GLPPost *)post callback:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    
    [[WebClient sharedInstance] getEventPostsAfterDate:post.dateEventStarts withCallbackBlock:^(BOOL success, NSArray *posts) {
        
        if(success)
        {
            callbackBlock(YES, posts);
        }
        else
        {
            callbackBlock(NO, posts);
        }
        
    }];
}

-(int)findMostCloseToNowLivePostWithPosts:(NSArray *)posts
{
    if(posts.count == 0 || !posts)
    {
        return 0;
    }
    
    NSDate *currentDate = [NSDate date];
    int ignorePosts = 0;

    //Cleanup posts of past dates.
    
    for(GLPPost *p in posts)
    {
        if ([[p dateEventStarts] compare:currentDate] == NSOrderedAscending)
        {
            ++ignorePosts;
        }
    }
    
    
    //Ignore past times.

    double min = [currentDate timeIntervalSinceDate:[[posts objectAtIndex:0] dateEventStarts]];;
    
    int minIndex = 0;
    
    if(ignorePosts != 0)
    {
        min = [currentDate timeIntervalSinceDate:[[posts objectAtIndex:ignorePosts-1] dateEventStarts]];
        minIndex = ignorePosts;

    }
    
    for (int i = ignorePosts; i < [posts count]; ++i)
    {
        double currentmin = [currentDate timeIntervalSinceDate:[[posts objectAtIndex:i] dateEventStarts]];
        
        
        if (currentmin > min)
        {
            min = currentmin;
            minIndex = i;
        }
    }
    
    return minIndex;
    
}

-(NSArray *)filterPosts:(NSArray *)posts
{
    NSMutableArray *finalPosts = [[NSMutableArray alloc] init];
    NSDate *tomorrow = [DateFormatterHelper generateDateWithLastMinutePlusDates:1];
    
    for(GLPPost *p in posts)
    {
        if ([[p dateEventStarts] compare:[NSDate date]] == NSOrderedAscending)
        {
            [finalPosts addObject:p];
        }
    }
    
    for(GLPPost *p in posts)
    {
        if([DateFormatterHelper date:[p dateEventStarts] isBetweenDate:[NSDate date] andDate:tomorrow])
        {
            [finalPosts addObject:p];
        }
    }
    
    return finalPosts;
}

#pragma mark - Notifications

- (void)notifyCampusLiveForNewPostsWithStatus:(BOOL)status
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CAMPUS_LIVE_POSTS_FETCHED object:self userInfo:@{@"posts_loaded_status" : @(status)}];
}


#pragma mark - Helpers

-(NSDate *)currentTime
{
    NSDate *date = [DateFormatterHelper generateTodayDateWhenItStarts];
    
    
    return date;
}

-(NSDate *)earlierTimeBeforeNumberOfDays:(int)numberOfDays
{
    NSDate *date = [DateFormatterHelper generateDateAfterDays:-numberOfDays];
    
    return date;
}

@end
