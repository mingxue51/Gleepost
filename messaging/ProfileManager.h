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

@property (assign, nonatomic, readonly) NSInteger userRemoteKey;

- (id)initWithUsersRemoteKey:(NSInteger)userRemoteKey;
- (void)getPosts;
- (void)loadPreviousPosts;
- (NSInteger)postsCount;
- (GLPPost *)postWithIndex:(NSInteger)index;
- (NSInteger)parseRefreshCellNotification:(NSNotification *)notification;
- (void)parseAndUpdatedViewsCountPostWithNotification:(NSNotification *)notification withCallbackBlock:(void (^) (NSInteger index))callback;
+ (NSString *)postsNotificationNameWithUserRemoteKey:(NSInteger)userRemoteKey;
+ (NSString *)previousPostsNotificationNameWithUserRemoteKey:(NSInteger)userRemoteKey;

@end
