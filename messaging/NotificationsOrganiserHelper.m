//
//  NotificationsOrganiserHelper.m
//  Gleepost
//
//  Created by Σιλουανός on 10/9/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class helps the GLPProfileViewController to organise the notifications
//  into sections and headers to view appropriately in table view.

#import "NotificationsOrganiserHelper.h"
#import "GLPNotification.h"
#import "DateFormatterHelper.h"

@interface NotificationsOrganiserHelper ()

@property (strong, nonatomic) NSString *recentHeader;
@property (strong, nonatomic) NSString *oldHeader;
@property (strong, nonatomic) NSMutableArray *sections;

@end

@implementation NotificationsOrganiserHelper


- (id)init
{
    self = [super init];
    
    if(self)
    {
        _recentHeader = @"RECENT";
        _oldHeader = @"OLD";
        _sections = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Modifiers

/**
 This method organise notifications in the following stucture:
 
 NSArray {NSDictionary (Header, NSArray<Notification>), ...}
 
 @param notifications an array of notifications.
 
 @returns the organised array.
 
 */
- (void)organiseNotifications:(NSArray *)notifications
{
//    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    NSDate *today = [NSDate date];
    
    NSDate *weekAgo = [DateFormatterHelper generateDateBeforeDays:7];
    
    for(GLPNotification *notification in notifications)
    {
        if ([DateFormatterHelper date:notification.date isBetweenDate:weekAgo andDate:today])
        {
            DDLogDebug(@"Recent notification: %@", notification.notificationTypeDescription);

            [self addNotification:notification withHeader:_recentHeader];
            
        }
        else
        {
            DDLogDebug(@"Older notification: %@", notification.notificationTypeDescription);
            
            [self addNotification:notification withHeader:_oldHeader];
        }
    }
    
    DDLogDebug(@"Final array: %@", _sections);
}

#pragma mark - Operations

- (void)addNotification:(GLPNotification *)notification withHeader:(NSString *)header
{
    NSDictionary *todaysDictionary = [self containsDictionaryWithHeader:header];
    
    if(todaysDictionary)
    {
        NSMutableArray *array = [todaysDictionary objectForKey:header];
        
        [array addObject:notification];
        
    }
    else
    {
        NSMutableArray *currentNotifications = @[notification].mutableCopy;
        todaysDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:currentNotifications, header, nil];
        [_sections addObject:todaysDictionary];
    }
    
}

- (void)setNotification:(GLPNotification *)notification withHeader:(NSString *)header
{
    NSDictionary *todaysDictionary = [self containsDictionaryWithHeader:header];
    
    if(todaysDictionary)
    {
        NSMutableArray *array = [todaysDictionary objectForKey:header];
        
        [array insertObject:notification atIndex:0];
    }
    else
    {
        NSMutableArray *currentNotifications = @[notification].mutableCopy;
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

- (NSArray *)notificationsAtSectionIndex:(NSInteger)sectionIndex
{
    NSDictionary *headerNotifications = [_sections objectAtIndex:sectionIndex];

    for(NSString *key in headerNotifications)
    {
        NSArray *notifications = [headerNotifications objectForKey:key];
        
        return notifications;
    }
    
    return nil;
}

- (NSInteger)lastSection
{
    return _sections.count;
}

- (GLPNotification *)notificationWithIndex:(NSInteger)notificationIndex andSectionIndex:(NSInteger)sectionIndex
{
    NSDictionary *headerNotifications = [_sections objectAtIndex:sectionIndex];
    
    for(NSString *key in headerNotifications)
    {
        NSArray *notifications = [headerNotifications objectForKey:key];
        
        return [notifications objectAtIndex:notificationIndex];
    }
    
    return nil;
}

@end
