//
//  AttendingPostsOrganiserHelper.m
//  Gleepost
//
//  Created by Silouanos on 26/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class helps the GLPAttendingPostsViewController to organise the posts
//  into sections and headers to view appropriately in table view.

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
        DDLogDebug(@"Post event starts %@, current date %@", post.dateEventStarts, [NSDate date]);
        
        if ([post.dateEventStarts compare:[NSDate date]] == NSOrderedDescending)
        {
            [self addPost:post withHeader:_recentHeader];
        }
        else
        {
            [self addPost:post withHeader:_oldHeader];
        }
    }
    
    DDLogDebug(@"Final event posts %@", _sections);
}

#pragma mark - Operations

- (void)addPost:(GLPPost *)post withHeader:(NSString *)header
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
        NSArray *posts = [headerPosts objectForKey:key];
        
        return posts;
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
        NSArray *posts = [headerPosts objectForKey:key];
        
        return [posts objectAtIndex:postIndex];
    }
    
    return nil;
}

- (NSIndexPath *)indexPathWithPost:(GLPPost *)post
{
    return [self indexPathWithPostRemoteKey:post.remoteKey];
}

- (NSIndexPath *)indexPathWithPostRemoteKey:(NSInteger)postRemoteKey
{
    NSInteger row = 0;
    NSInteger section = 0;
    
    for(NSDictionary *sectionDict in _sections)
    {
        NSArray *postsSection = [sectionDict objectForKey:[[sectionDict allKeys] objectAtIndex:0]];
        
        for(GLPPost *p in postsSection)
        {
            if(p.remoteKey == postRemoteKey)
            {
                return [NSIndexPath indexPathForItem:row inSection:section];
            }
            ++row;
        }
        row = 0;
        
        ++section;
    }
    
    return nil;
}

- (NSIndexPath *)updatePostWithRemoteKey:(NSInteger)postRemoteKey andViewsCount:(NSInteger)viewsCount
{
    NSInteger row = 0;
    NSInteger section = 0;
    
    for(NSDictionary *sectionDict in _sections)
    {
        NSArray *postsSection = [sectionDict objectForKey:[[sectionDict allKeys] objectAtIndex:0]];
        
        for(GLPPost *p in postsSection)
        {
            if(p.remoteKey == postRemoteKey)
            {
                p.viewsCount = viewsCount;
                return [NSIndexPath indexPathForItem:row inSection:section];
            }
            ++row;
        }
        row = 0;
        
        ++section;
    }
    
    return nil;
}

- (NSIndexPath *)removePost:(GLPPost *)post
{
    NSIndexPath *indexPath = [self indexPathWithPost:post];
    
    NSMutableDictionary *section = [NSMutableDictionary dictionaryWithDictionary:[_sections objectAtIndex:indexPath.section]];
    
    NSMutableArray *postsSection = [section objectForKey:[[section allKeys] objectAtIndex:0]];
    
    [postsSection removeObjectAtIndex:indexPath.row];
        
    [_sections setObject:section atIndexedSubscript:indexPath.section];
    
    DDLogDebug(@"Post removed. New sections %@", _sections);
    return indexPath;
}

- (GLPPost *)lastPost
{
    NSString *lastHeader = [self headerInSection:[self lastSection]-1];
    NSDictionary *dictionary = [self containsDictionaryWithHeader:lastHeader];
    NSArray *postsSection = [dictionary objectForKey:[[dictionary allKeys] objectAtIndex:0]];
    return [postsSection lastObject];
}


@end
