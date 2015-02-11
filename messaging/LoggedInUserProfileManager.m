//
//  LoggedInUserProfileManager.m
//  Gleepost
//
//  Created by Silouanos on 06/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "LoggedInUserProfileManager.h"
#import "SessionManager.h"
#import "GLPPostNotificationHelper.h"
#import "GLPProfileLoader.h"

@class GLPUser;

@interface LoggedInUserProfileManager ()

@property (strong, nonatomic) GLPUser *loggedInUser;

@end

@implementation LoggedInUserProfileManager

- (instancetype)init
{
    self = [super initWithUsersRemoteKey:[SessionManager sharedInstance].user.remoteKey];
    
    if (self)
    {
        [self intialiseObjects];
    }
    return self;
}

- (void)intialiseObjects
{
    _loggedInUser = nil;
}

- (NSInteger)removePostWithPost:(GLPPost *)post
{
    [GLPPostNotificationHelper deletePostNotificationWithPostRemoteKey:post.remoteKey inCampusLive:NO];
    
    NSInteger index = [self.posts indexOfObject:post];;
    
    if(index != NSNotFound)
    {
        [self.posts removeObjectAtIndex:index];
    }
    
    return index;
}

- (void)getUserData
{
    [self fetchUserData];
}

- (void)fetchUserData
{
    [[GLPProfileLoader sharedInstance] loadUsersDataWithLocalCallback:^(GLPUser *user) {
        
        if(user && ![user isEqual:_loggedInUser])
        {
            _loggedInUser = user;
            DDLogDebug(@"Data needs to be updated locally: %@", user);
            [self sendNotificationUsersDataFetched];
        }
        
    } andRemoteCallback:^(BOOL success, BOOL updatedData, GLPUser *user) {
        
        if(success && updatedData)
        {
            DDLogDebug(@"Data needs to be updated remotely: %@", user);
            _loggedInUser = user;
            [self sendNotificationUsersDataFetched];
        }
    }];
}

/**
 Updates the specific post's social data (including number of likes and comments).
 
 @param notification contains the updated social data/
 */
- (NSInteger)updateSocialDataPostWithNotification:(NSNotification *)notification
{
    return [GLPPostNotificationHelper parseNotification:notification withPostsArray:self.posts];
}

- (void)updateLikedPostWithNotification:(NSNotification *)notification
{
    [GLPPostNotificationHelper parseLikedPostNotification:notification withPostsArray:self.posts];
}

#pragma mark - Post notifications

- (void)sendNotificationUsersDataFetched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_LOGGED_IN_USERS_DATA_FETCHED object:self userInfo:@{@"user_data" : _loggedInUser}];
}


@end
