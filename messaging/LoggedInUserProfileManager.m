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

@implementation LoggedInUserProfileManager

- (instancetype)init
{
    self = [super initWithUsersRemoteKey:[SessionManager sharedInstance].user.remoteKey];
    
    if (self) {
    }
    return self;
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

@end
