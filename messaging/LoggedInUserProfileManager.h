//
//  LoggedInUserProfileManager.h
//  Gleepost
//
//  Created by Silouanos on 06/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "ProfileManager.h"

@interface LoggedInUserProfileManager : ProfileManager

- (NSInteger)removePostWithPost:(GLPPost *)post;
- (NSInteger)updateSocialDataPostWithNotification:(NSNotification *)notification;
- (void)updateLikedPostWithNotification:(NSNotification *)notification;

@end
