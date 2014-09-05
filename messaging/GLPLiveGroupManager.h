//
//  GLPLiveGroupManager.h
//  Gleepost
//
//  Created by Σιλουανός on 29/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPGroup;

@interface GLPLiveGroupManager : NSObject

+ (GLPLiveGroupManager *)sharedInstance;

- (void)loadGroups;

- (void)loadGroupsWithPendingGroups:(NSArray *)pending withLiveCallback:(void (^) (NSArray* groups))local remoteCallback:(void (^) (BOOL success, NSArray *remoteGroups))remote;

- (void)addUnreadPostWithGroupRemoteKey:(NSInteger)groupKey;

- (void)postGroupReadWithRemoteKey:(NSInteger)groupKey;

- (NSInteger)numberOfUnseenPostsWithGroup:(GLPGroup *)group;

- (NSArray *)liveGroups;

@end
