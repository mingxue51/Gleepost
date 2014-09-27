//
//  GLPLiveGroupPostManager.h
//  Gleepost
//
//  Created by Silouanos on 25/09/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;
@class UploadingProgressView;

@interface GLPLiveGroupPostManager : NSObject

+ (GLPLiveGroupPostManager *)sharedInstance;

//Progress view methods

- (void)registerVideoWithTimestamp:(NSDate *)timestamp withPost:(GLPPost *)post;
- (UploadingProgressView *)progressView;
- (void)setThumbnailImage:(UIImage *)thumbnail;
- (void)progressFinished;
- (void)postButtonClicked;
- (BOOL)isProgressFinished;
- (NSDate *)registeredTimestamp;
- (NSString *)generateNSNotificationNameForPendingGroupPost;

- (void)addImagePost:(GLPPost *)post withGroupRemoteKey:(NSInteger)groupRemoteKey;
- (NSArray *)pendingImagePostsWithGroupRemoteKey:(NSInteger)groupRemoteKey;
- (void)removePost:(GLPPost *)post fromGroupWithRemoteKey:(NSInteger)groupRemoteKey;
- (void)removeAnyUploadedImagePostWithPosts:(NSArray *)posts inGroupRemoteKey:(NSInteger)groupRemoteKey;

@end
