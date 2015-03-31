//
//  GLPUploadingGroupStatusHelper.m
//  Gleepost
//
//  Created by Silouanos on 31/03/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Helper that has all the progress status of all the groups that are uploading. This is used in the GLPGroupCell in order
//  to take the current uploading status in case the group image uploaded and user hits the create group button.
//  NOTE: The most of the following implementation is unused. We assuming that only one group needs this data each time (and that's true).

#import "GLPUploadingGroupStatusHelper.h"

@interface GLPUploadingGroupStatusHelper ()

/** Contains <group_key, uploading_progress> */
@property (strong, nonatomic) NSMutableDictionary *pendingGroups;

@property (assign, nonatomic) CGFloat currentGroupProgress;

@end

@implementation GLPUploadingGroupStatusHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self configureObjects];
    }
    return self;
}

- (void)configureObjects
{
    self.pendingGroups = [[NSMutableDictionary alloc] init];
    self.currentGroupProgress = -1.0;
}


#pragma mark - Registration progress status

/**
 This method should be called when user cancels the creating of a new group
 or after the uploading is completed.
 
 @param groupKey The group key.
 
 */

- (void)unregisterGroupWithKey:(NSInteger)groupKey
{
    NSString *notificationName = [self generateGroupCellNotificationWithGroupKey:groupKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    [self.pendingGroups removeObjectForKey:@(groupKey)];
}

/**
 This method should be called once image started uploading.
 
 @param groupKey The group key.
 
 */
- (void)registerGroupWithKey:(NSInteger)groupKey
{
    NSString *notificationName = [self generateGroupCellNotificationWithGroupKey:groupKey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressReceived:) name:notificationName object:nil];
}

- (void)unregisterGroup
{
    self.currentGroupProgress = -1.0;
    [self unregisterGroupWithKey:0];
}

- (void)registerGroup
{
    self.currentGroupProgress = 0.0;
    [self registerGroupWithKey:0];
}


#pragma mark - Accessors

- (CGFloat)uploadingGroupProgress
{
    return self.currentGroupProgress;
}

/**
 This method should be called from GLPGroupCell when a group cell recognises
 that the group is local.
 
 @param groupKey The group key.
 
 */
- (CGFloat)uploadingGroupProgressWithKey:(NSInteger)groupKey
{
    NSNumber *result = [self.pendingGroups objectForKey:@(groupKey)];
    
    if(!result)
    {
        return -1;
    }

    return [result floatValue];
}

#pragma mark - NSNotification methods

- (void)progressReceived:(NSNotification *)notification
{
    NSInteger groupKey = [self groupKeyFromNotificationName:notification.name];
    float uploadedProgress = [notification.userInfo[@"uploaded_progress"] floatValue];

    
    [self.pendingGroups setObject:@(uploadedProgress) forKey:@(groupKey)];
    
    self.currentGroupProgress = uploadedProgress;
}

#pragma mark - Dispose

- (void)dealloc
{
    self.pendingGroups = nil;
    
}

#pragma mark - Helpers

- (NSString *)generateGroupCellNotificationWithGroupKey:(NSInteger)key
{
    return [NSString stringWithFormat:@"%ld_%@", (long)key, GLPNOTIFICATION_NEW_GROUP_IMAGE_PROGRESS];
}

- (NSInteger)groupKeyFromNotificationName:(NSString *)notificationName
{
    NSArray *result = [notificationName componentsSeparatedByString:@"_"];
    
    return [result[0] integerValue];
}

@end
