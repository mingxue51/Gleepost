//
//  GLPLiveGroupManager.h
//  Gleepost
//
//  Created by Σιλουανός on 29/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPGroup;
@class ChangeGroupImageProgressView;
@class GLPNotification;

@interface GLPLiveGroupManager : NSObject

+ (GLPLiveGroupManager *)sharedInstance;

- (void)loadGroups;

- (void)loadGroupsIfNeededWithNewNotification:(GLPNotification *)notification;

- (void)loadGroupsWithPendingGroups:(NSArray *)pending withLiveCallback:(void (^) (NSArray* groups))local remoteCallback:(void (^) (BOOL success, NSArray *remoteGroups))remote;

- (GLPGroup *)groupWithRemoteKey:(NSInteger)groupRemoteKey;

- (void)addUnreadPostWithGroupRemoteKey:(NSInteger)groupKey;

- (void)postGroupReadWithRemoteKey:(NSInteger)groupKey;

- (NSInteger)numberOfUnseenPostsWithGroup:(GLPGroup *)group;

- (NSArray *)liveGroups;

- (ChangeGroupImageProgressView *)progressViewWithGroup:(GLPGroup *)group;

- (void)startChangeImageProgressingWithGroup:(GLPGroup *)group;

- (void)finishUploadingNewImageToGroup:(GLPGroup *)group;

- (NSDate *)timestampWithGroupRemoteKey:(NSInteger)groupRemoteKey;

@end
