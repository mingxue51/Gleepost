//
//  GLPVideoLoaderManager.h
//  Gleepost
//
//  Created by Silouanos on 23/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;
@class PBJVideoPlayerController;

@interface GLPVideoLoaderManager : NSObject

+ (GLPVideoLoaderManager *)sharedInstance;


-(void)addVideoPosts:(NSArray *)posts;
//- (void)videoWithPostRemoteKey:(NSInteger)remoteKey;
- (void)visiblePosts:(NSArray *)visiblePosts;
- (void)disableTimelineJustFetched;
- (PBJVideoPlayerController *)setVideoWithPost:(GLPPost *)post;
- (PBJVideoPlayerController *)videoWithPostRemoteKey:(NSInteger)remoteKey;
//- (void)configureVideoPlayerControllerAndPostNotificationWithRemoteKey:(NSNumber *)remoteKey callbackBlock:(void (^) (NSNumber *remoteKey, PBJVideoPlayerController *player))callbackBlock;
//- (void)setVideoPost:(GLPPost *)post;
//- (void)removeVideoPost:(GLPPost *)post;
@end
