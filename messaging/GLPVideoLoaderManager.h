//
//  GLPVideoLoaderManager.h
//  Gleepost
//
//  Created by Silouanos on 23/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBJVideoPlayerController;

@interface GLPVideoLoaderManager : NSObject

+ (GLPVideoLoaderManager *)sharedInstance;


-(void)addVideoPosts:(NSArray *)posts;
//- (void)addVideoWithUrl:(NSString *)videoUrl andPostRemoteKey:(NSInteger)remoteKey;
- (void)videoWithPostRemoteKey:(NSInteger)remoteKey;
- (void)visiblePosts:(NSArray *)visiblePosts;
//- (void)releaseVideo;
- (void)addVideoWithUrl:(NSString *)videoUrl andPostRemoteKey:(NSInteger)remoteKey;
- (void)configureVideoPlayerControllerAndPostNotificationWithRemoteKey:(NSNumber *)remoteKey callbackBlock:(void (^) (NSNumber *remoteKey, PBJVideoPlayerController *player))callbackBlock;

@end
