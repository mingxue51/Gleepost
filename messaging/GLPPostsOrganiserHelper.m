//
//  GLPPostsOrganiserHelper.m
//  Gleepost
//
//  Created by Silouanos on 26/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class is a super class of all the posts organiser helpers classes.



#import "GLPPostsOrganiserHelper.h"

@interface GLPPostsOrganiserHelper ()

@property (strong, nonatomic) NSMutableArray *sections;

@end

@implementation GLPPostsOrganiserHelper

- (id)initWithFirstHeader:(NSString *)firstHeader andSecondHeader:(NSString *)secondHeader
{
    self = [super init];
    
    if(self)
    {
        _firstHeader = firstHeader;
        _secondHeader = secondHeader;
        _sections = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark - Operations

- (void)addPost:(GLPPost *)post withHeader:(NSString *)header
{
    NSDictionary *currentDictionary = [self containsDictionaryWithHeader:header];
    
    if(currentDictionary)
    {
        NSMutableArray *array = [currentDictionary objectForKey:header];
        
        [array addObject:post];
    }
    else
    {
        NSMutableArray *currentNotifications = @[post].mutableCopy;
        currentDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:currentNotifications, header, nil];
        [_sections addObject:currentDictionary];
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
    
    if(sectionIndex == 0)
    {
        return self.firstHeader;
    }
    else if(sectionIndex == 1)
    {
        return self.secondHeader;
    }
    else
    {
        return @"Unknown header";
    }
    
//    NSDictionary *header = [_sections objectAtIndex:sectionIndex];
//    
//    for(NSString *key in header)
//    {
//        return key;
//    }
//    
//    return nil;
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

- (NSIndexPath *)indexPathWithPost:(GLPPost *)post
{
    NSInteger row = 0;
    NSInteger section = 0;
    
    for(NSDictionary *sectionDict in _sections)
    {
        NSArray *postsSection = [sectionDict objectForKey:[[sectionDict allKeys] objectAtIndex:0]];
        
        for(GLPPost *p in postsSection)
        {
            if(p.remoteKey == post.remoteKey)
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

@end
