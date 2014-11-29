//
//  GLPPendingPostsManager.h
//  Gleepost
//
//  Created by Silouanos on 24/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class manages all the operations with pending posts including remove pending post, add new pending post
//  or editing. As a result is responsible for all the interactions with the local database via GLPReviewHistoryDao,
//  GLPPostDao or other Dao and manager classes.

#import <Foundation/Foundation.h>

@class GLPPost;

@interface GLPPendingPostsManager : NSObject

+ (GLPPendingPostsManager *)sharedInstance;

- (NSMutableArray *)pendingPosts;
- (NSInteger)numberOfPendingPosts;
- (BOOL)arePendingPosts;
- (void)loadPendingPostsWithLocalCallback:(void (^) (NSArray *localPosts))localCallback withRemoteCallback:(void (^) (BOOL success, NSArray *remotePosts))remoteCallback;
- (void)addNewPendingPost:(GLPPost *)pendingPost;
- (void)updatePendingPost:(GLPPost *)pendingPost;
- (void)removePendingPost:(GLPPost *)pendingPost;

@end
