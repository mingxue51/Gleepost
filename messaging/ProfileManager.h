//
//  ProfileManager.h
//  Gleepost
//
//  Created by Silouanos on 06/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

@interface ProfileManager : NSObject

- (id)initWithUsersRemoteKey:(NSInteger)userRemoteKey;
- (void)getPosts;
- (void)loadPreviousPosts;
+ (NSString *)notificationNameWithUserRemoteKey:(NSInteger)userRemoteKey;

@end
