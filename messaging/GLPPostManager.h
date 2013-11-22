//
//  GLPPostManager.h
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"

@interface GLPPostManager : NSObject

extern NSInteger const kGLPNumberOfPosts;

+ (void)loadInitialPostsWithLocalCallback:(void (^)(NSArray *localPosts))localCallback remoteCallback:(void (^)(BOOL success, BOOL remain, NSArray *remotePosts))remoteCallback;
+ (void)loadLocalPostsBefore:(GLPPost *)post callback:(void (^)(NSArray *posts))callback;
+ (void)loadRemotePostsBefore:(GLPPost *)post callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback;
+ (void)loadPreviousPostsAfter:(GLPPost *)post callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback;
+(void)loadPostWithRemoteKey:(int)remoteKey callback:(void (^)(BOOL sucess, GLPPost* post))callback;
+ (void)createLocalPost:(GLPPost*)post;
+ (void)updatePostAfterSending:(GLPPost *)post;
+(void)updatePostWithLiked:(GLPPost*)post;

@end
