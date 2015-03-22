//
//  UserProfileManager.m
//  Gleepost
//
//  Created by Silouanos on 06/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "UserProfileManager.h"
#import "ContactsManager.h"

@implementation UserProfileManager


- (void)getUserData
{
    [[ContactsManager sharedInstance] loadUserWithRemoteKey:self.userRemoteKey localCallback:^(BOOL exist, GLPUser *user) {
        
        if(exist)
        {
            [self sendNotificationWithUser:user];
        }
        
    } remoteCallback:^(BOOL success, GLPUser *user) {
        
        if(success)
        {
            [self sendNotificationWithUser:user];
        }
        
    }];
}

#pragma mark - Post notifications

- (void)sendNotificationWithUser:(GLPUser *)user
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_USERS_DATA_FETCHED object:self userInfo:@{@"user_data" : user}];
}

@end
