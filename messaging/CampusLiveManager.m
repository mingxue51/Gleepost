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
#import "GLPPostNotificationHelper.h"
#import "GLPVideoLoaderManager.h"
#import "GLPLiveSummaryDao.h"

@interface CampusLiveManager ()

@property (strong, nonatomic) NSArray *liveEventPosts;

/** Helps to return in O(1) complexity posts' index. <postRemoteKey, index>. NOT USED for now. */
@property (strong, nonatomic) NSMutableDictionary *liveEventPostDictionary;

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
        self.liveEventPostDictionary = [[NSMutableDictionary alloc] init];
        self.liveSummary = [[GLPLiveSummary alloc] init];
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
                [[GLPVideoLoaderManager sharedInstance] addVideoPosts:posts];
                self.liveEventPosts = posts;
            }
            
            [self notifyCampusLiveForNewPostsWithStatus:success];
            
        }];
        
    });

}

- (void)getLiveSummary
{
    GLPLiveSummary *liveSummary = [GLPLiveSummaryDao findCurrentLiveSummary];
    
    self.liveSummary = (liveSummary) ? liveSummary : self.liveSummary;
    
    [self notifyCampusWallTopViewWithStatus:YES];
    
    NSDate *tomorrow = [DateFormatterHelper generateDateWithLastMinutePlusDates:1];
    
    [[WebClient sharedInstance] campusLiveSummaryUntil:tomorrow callbackBlock:^(BOOL success, GLPLiveSummary *liveSummary) {
       
        if(success)
        {
            [GLPLiveSummaryDao saveLiveSummary:liveSummary];
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

- (NSInteger)indexOfPostWithRemoteKey:(NSInteger)postRemoteKey
{
//    NSInteger index = 0;
//    
//    for(GLPPost *p in self.liveEventPosts)
//    {
//        if(p.remoteKey == postRemoteKey)
//        {
//            return index;
//        }
//        ++index;
//    }
//    
//    return NSNotFound;
    
     return [[self.liveEventPostDictionary objectForKey:@(postRemoteKey)] integerValue];
}

- (NSInteger)eventsCount
{
    DDLogDebug(@"CampusLiveManager eventsCount %lu", (unsigned long)self.liveEventPosts.count);
    
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

#pragma mark - Modifiers

- (void)deletePostWithPost:(GLPPost *)postToBeDeleted
{
    NSMutableArray *liveEventPostsMutable = self.liveEventPosts.mutableCopy;
    
    NSInteger index = 0;
    
    for(GLPPost *post in self.liveEventPosts)
    {
        if(post.remoteKey == postToBeDeleted.remoteKey)
        {
            [liveEventPostsMutable removeObjectAtIndex:index];
            break;
        }
        ++index;
    }
    
    self.liveEventPosts = liveEventPostsMutable;
    [self deletePostFromServerWithPost:postToBeDeleted];
}

#pragma mark - Client

- (void)deletePostFromServerWithPost:(GLPPost *)post
{
    [[WebClient sharedInstance] deletePostWithRemoteKey:post.remoteKey callbackBlock:^(BOOL success) {
       
        if(success)
        {
            [GLPPostManager deletePostWithPost:post];
            [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey inCampusLive:YES];
        }
        
    }];
}

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
            [self savePostsInLocalDatabaseAndInDictionary:posts];
            
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_GOING_BUTTON_TOUCHED object:self userInfo:@{@"post" : post, @"attend" : @(attend), @"post_image" : (postImage) ? postImage : [NSNull null]}];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_GOING_BUTTON_UNTOUCHED object:self userInfo:@{@"post" : post, @"attend" : @(attend)}];
    }
    
}

- (void)savePostsInLocalDatabaseAndInDictionary:(NSArray *)posts
{
    
    NSInteger index = 0;
    
    for(GLPPost *post in posts)
    {
        [GLPPostDao saveOrUpdatePost:post];
        [self.liveEventPostDictionary setObject:@(index) forKey:@(post.remoteKey)];
        ++index;
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

- (void)clearData
{
    instance = [[CampusLiveManager alloc] init];
}

@end
