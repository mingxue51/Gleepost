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


typedef NS_ENUM(NSUInteger, GroupsLoadedStatus) {
    kLocalLoaded,
    kRemoteLoaded,
    kNotLoaded
};

@interface GLPLiveGroupManager : NSObject

+ (GLPLiveGroupManager *)sharedInstance;

- (void)loadInitialGroups;

- (void)loadGroupsIfNeededWithNewNotification:(GLPNotification *)notification;

- (void)loadGroupsWithPendingGroups:(NSArray *)pending withLiveCallback:(void (^) (NSArray* groups))local remoteCallback:(void (^) (BOOL success, NSArray *remoteGroups))remote;

- (GLPGroup *)groupWithRemoteKey:(NSInteger)groupRemoteKey;
- (NSInteger)getPendingGroupKeyWithTimestamp:(NSDate *)timestamp;
- (void)deleteGroup:(GLPGroup *)group;

- (void)userJoinedGroup;

- (void)addUnreadPostWithGroupRemoteKey:(NSInteger)groupKey;

- (void)postGroupReadWithRemoteKey:(NSInteger)groupKey;

- (NSInteger)numberOfUnseenPostsWithGroup:(GLPGroup *)group;

- (void)getGroups;

- (void)newGroupToBeCreated:(GLPGroup *)pendingGroup withTimestamp:(NSDate *)timestamp;
- (void)updateGroupAfterCreated:(GLPGroup *)createdGroup;
- (void)clearData;

- (ChangeGroupImageProgressView *)progressViewWithGroup:(GLPGroup *)group;

- (void)startChangeImageProgressingWithGroup:(GLPGroup *)group;

- (void)finishUploadingNewImageToGroup:(GLPGroup *)group;
- (void)clearUploadingNewImageToGroup:(GLPGroup *)group;

- (void)searchGroupsWithQuery:(NSString *)query;
- (void)loadUsersGroupsWithRemoteKey:(NSInteger)userRemoteKey;

- (NSDate *)timestampWithGroupRemoteKey:(NSInteger)groupRemoteKey;

- (void)registerUploadingGroup;
- (void)unregisterUploadingGroup;
- (CGFloat)uploadingGroupProgress;

@end
