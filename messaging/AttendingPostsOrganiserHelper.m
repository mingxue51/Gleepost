//
//  AttendingPostsOrganiserHelper.m
//  Gleepost
//
//  Created by Silouanos on 26/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class helps the GLPAttendingPostsViewController to organise the posts
//  into sections and headers to view appropriately in table view.


//    if([self.post.dateEventStarts compare:[NSDate date]] == NSOrderedAscending)

#import "AttendingPostsOrganiserHelper.h"
#import "GLPPost.h"

@interface AttendingPostsOrganiserHelper ()

@property (strong, nonatomic) NSString *recentHeader;
@property (strong, nonatomic) NSString *oldHeader;
@property (strong, nonatomic) NSMutableArray *sections;

@end

@implementation AttendingPostsOrganiserHelper

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _recentHeader = @"UPCOMING EVENTS";
        _oldHeader = @"PAST EVENTS";
        _sections = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/**
 This method organise notifications in the following stucture:
 
 NSArray {NSDictionary (Header, NSArray<Notification>), ...}
 
 @param notifications an array of notifications.
 
 @returns the organised array.
 
 */
- (void)organisePosts:(NSArray *)posts
{
    for(GLPPost *post in posts)
    {
        if ([post.dateEventStarts compare:[NSDate date]] == NSOrderedAscending)
        {
            [self addNotification:post withHeader:_recentHeader];
        }
        else
        {
            [self addNotification:post withHeader:_oldHeader];
        }
    }
}

#pragma mark - Operations

- (void)addNotification:(GLPPost *)post withHeader:(NSString *)header
{
    NSDictionary *todaysDictionary = [self containsDictionaryWithHeader:header];
    
    if(todaysDictionary)
    {
        NSMutableArray *array = [todaysDictionary objectForKey:header];
        
        [array addObject:post];
        
    }
    else
    {
        NSMutableArray *currentNotifications = @[post].mutableCopy;
        todaysDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:currentNotifications, header, nil];
        [_sections addObject:todaysDictionary];
    }
    
}

- (NSDictionary *)containsDictionaryWithHeader:(NSString *)header
{
    for(NSDictionary *dictonary in _sections)
    {
        if([dictonary objectForKey:header])
        {
            return dictonary;
        }
    }
    
    return nil;
}

#pragma mark - Accessors

- (void)resetData
{
    DDLogDebug(@"SECTIONS POSTS %@", _sections);
    
    [_sections removeAllObjects];
}

- (NSInteger)numberOfSections
{
    return _sections.count;
}

- (NSString *)headerInSection:(NSInteger)sectionIndex
{
    NSDictionary *header = [_sections objectAtIndex:sectionIndex];
    
    for(NSString *key in header)
    {
        return key;
    }
    
    return nil;
}

- (NSArray *)postsAtSectionIndex:(NSInteger)sectionIndex
{
    NSDictionary *headerPosts = [_sections objectAtIndex:sectionIndex];
    
    for(NSString *key in headerPosts)
    {
        NSArray *notifications = [headerPosts objectForKey:key];
        
        return notifications;
    }
    
    return nil;
}

- (NSInteger)lastSection
{
    return _sections.count;
}

- (GLPPost *)postWithIndex:(NSInteger)postIndex andSectionIndex:(NSInteger)sectionIndex
{
    NSDictionary *headerPosts = [_sections objectAtIndex:sectionIndex];
    
    for(NSString *key in headerPosts)
    {
        NSArray *notifications = [headerPosts objectForKey:key];
        
        return [notifications objectAtIndex:postIndex];
    }
    
    return nil;
}


@end
