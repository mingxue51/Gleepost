//
//  GLPLiveGroupPostManager.h
//  Gleepost
//
//  Created by Silouanos on 25/09/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPost;

@interface GLPLiveGroupPostManager : NSObject

+ (GLPLiveGroupPostManager *)sharedInstance;

- (void)addImagePost:(GLPPost *)post withGroupRemoteKey:(NSInteger)groupRemoteKey;
- (NSArray *)pendingImagePostsWithGroupRemoteKey:(NSInteger)groupRemoteKey;
- (void)removePost:(GLPPost *)post fromGroupWithRemoteKey:(NSInteger)groupRemoteKey;
- (void)removeAnyUploadedImagePostWithPosts:(NSArray *)posts inGroupRemoteKey:(NSInteger)groupRemoteKey;

@end
