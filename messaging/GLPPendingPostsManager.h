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
@class UploadingProgressView;

@interface GLPPendingPostsManager : NSObject

+ (GLPPendingPostsManager *)sharedInstance;

- (NSMutableArray *)pendingPosts;
- (NSInteger)numberOfPendingPosts;
- (BOOL)arePendingPosts;
- (void)loadPendingPosts;
- (void)loadPendingPostsWithLocalCallback:(void (^) (NSArray *localPosts))localCallback withRemoteCallback:(void (^) (BOOL success, NSArray *remotePosts))remoteCallback;
- (GLPPost *)postWithRemoteKey:(NSInteger)postRemoteKey;

- (UploadingProgressView *)progressViewWithPostRemoteKey:(NSInteger)postRemoteKey;
- (void)registerVideoWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post;
- (void)setThumbnailImage:(UIImage *)thumbnail;
- (void)progressFinished;
- (void)postButtonClicked;
- (BOOL)isProgressFinished;
- (NSDate *)registeredTimestamp;
- (NSString *)generateNSNotificationNameForPendingPost;
- (NSString *)generateNSNotificationUploadFinshedNameForPendingPost;

- (void)addNewPendingPost:(GLPPost *)pendingPost;
- (void)updateNewPendingPostInEditMode:(GLPPost *)pendingPost;
- (void)updatePendingPostAfterEdit:(GLPPost *)pendingPost;
- (void)updatePendingPostBeforeEdit:(GLPPost *)pendingPost;
- (void)removePendingPost:(GLPPost *)pendingPost;
- (void)clean;

@end
