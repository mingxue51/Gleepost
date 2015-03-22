//
//  GLPSearchGroups.m
//  Gleepost
//
//  Created by Silouanos on 28/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Helper class that helps the GLPLiveGroupManager to manage searching groups operations.

#import "GLPSearchGroups.h"
#import "WebClient.h"

@implementation GLPSearchGroups

- (void)searchGroupsWithQuery:(NSString *)query
{
    [[WebClient sharedInstance] searchGroupsWithName:query callback:^(BOOL success, NSArray *groups) {
       
        [self notifyAfterQueryWithSuccess:success withGroups:groups andQuery:query];
        
    }];
}

- (void)loadGroupWithUserRemoteKey:(NSInteger)userRemoteKey
{
    [[WebClient sharedInstance] searchGroupsWithUsersRemoteKey:userRemoteKey callback:^(BOOL success, NSArray *groups) {
        [self notifyAfterUsersGroupsLoadedWithSuccess:success withGroups:groups];
    }];
}

- (void)notifyAfterUsersGroupsLoadedWithSuccess:(BOOL)success withGroups:(NSArray *)groups
{
    if(!groups)
    {
        groups = [[NSArray alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_USER_GROUPS_LOADED object:self userInfo:@{@"groups": groups, @"success" : @(success)}];
}

/**
 Notifies GLPGroupSearchViewController after performed a search for groups operation.
 
 @param success YES if the request successed and NO if not.
 @param groups the groups' result.
 
 */
- (void)notifyAfterQueryWithSuccess:(BOOL)success withGroups:(NSArray *)groups andQuery:(NSString *)query
{
    
    if(!groups)
    {
        groups = [[NSArray alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_GROUPS_FECTHED_AFTER_QUERY object:self userInfo:@{@"groups": groups, @"success" : @(success), @"query" : query}];
}

@end
