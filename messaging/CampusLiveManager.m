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
#import "GLPLiveSummary.h"
#import "DateFormatterHelper.h"
#import "GLPPostManager.h"

@interface CampusLiveManager ()

@property (strong, nonatomic) NSArray *liveEventPosts;
@property (strong, nonatomic) GLPLiveSummary *liveSummary;
@property (strong, nonatomic) dispatch_queue_t queue;

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

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.queue = dispatch_queue_create("com.gleepost.queue.campuslivemanager", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - Client accessors

/**
 Informs the manager that the GLPCampusLiveViewController needs the posts.
 The manager loads posts and sends them to the GLPCampusLiveViewController (via NSNotification).
 */
- (void)getLiveEventPosts
{
    dispatch_sync(_queue, ^{

        [self loadCurrentLivePostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
            
            if(success)
            {
                self.liveEventPosts = posts;
            }
            
            [self notifyCampusLiveForNewPostsWithStatus:success];
            
        }];
        
    });

}

- (void)getLiveSummary
{
    NSDate *tomorrow = [DateFormatterHelper generateDateWithLastMinutePlusDates:1];
    
    [[WebClient sharedInstance] campusLiveSummaryUntil:tomorrow callbackBlock:^(BOOL success, GLPLiveSummary *liveSummary) {
       
        if(success)
        {
            DDLogDebug(@"CampusLiveManager getLiveSummary");
            
            self.liveSummary = liveSummary;
        }
        
        [self notifyCampusWallTopViewWithStatus:success];
        
    }];
}

#pragma mark - Simple accessors

- (GLPPost *)eventPostAtIndex:(NSInteger)index
{
    return [self.liveEventPosts objectAtIndex:index];
}

- (NSInteger)eventsCount
{
    return self.liveEventPosts.count;
}

- (NSInteger)liveSummaryPartiesCount
{
    return [self.liveSummary partiesPostCount];
}

- (NSInteger)liveSummarySpeakersCount
{
    return [self.liveSummary speakersPostCount];
}

- (NSInteger)liveSummaryPostsLeftCount
{
    return [self.liveSummary eventsLeftCount];
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

- (void)attendToEvent:(BOOL)attend withPostRemoteKey:(NSInteger)postRemoteKey withImage:(UIImage *)postImage
{
    GLPPost *post = [self findPostWithRemoteKey:postRemoteKey];
    
    if(!post)
    {
        DDLogError(@"CampusLiveManager attend to event failed. Post could not be found.");
        return;
    }
    
    DDLogDebug(@"CampusLiveManager attend to event post %@", post);
    post.attended = attend;
    
    [[WebClient sharedInstance] attendEvent:attend withPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success, NSInteger popularity) {
        
        if(success)
        {
            //Update local database.
            [GLPPostManager updatePostAttending:post];
        }
        else
        {
            //TODO: If failed retry. (manager that will manage attending background operations).
            
//            [self makeButtonSelected];
//            
//            [WebClientHelper showInternetConnectionErrorWithTitle:@"Not attending to the event failed."];
        }
        
    }];
    
    if(attend)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:self userInfo:@{@"post" : post, @"attend" : @(attend), @"post_image" : postImage}];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_GOING_BUTTON_UNTOUCHED object:self userInfo:@{@"post" : post, @"attend" : @(attend)}];
    }
    
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

- (GLPPost *)findPostWithRemoteKey:(NSInteger)postRemoteKey
{
    NSPredicate *postPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"remoteKey = %ld", (long)postRemoteKey]];
    
    NSArray *post = [self.liveEventPosts filteredArrayUsingPredicate:postPredicate];

    if(!post)
    {
        return nil;
    }
    
    return post[0];
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

- (void)notifyCampusWallTopViewWithStatus:(BOOL)status
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CAMPUS_LIVE_SUMMARY_FETCHED object:self userInfo:@{@"campus_live_summary_status" : @(status)}];
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
