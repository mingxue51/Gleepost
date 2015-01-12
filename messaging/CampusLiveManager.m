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

#pragma mark - Client

-(void)loadCurrentLivePostsWithCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock
{
    [[WebClient sharedInstance] getEventPostsAfterDate:[self currentTime] withCallbackBlock:^(BOOL success, NSArray *posts) {
        
        //TODO: remove that when is supported by the server.
        posts = [self filterPosts:posts];
        
        if(success)
        {
            callbackBlock(YES, posts);
        }
        else
        {
            callbackBlock(NO, nil);
        }
        
    }];
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
