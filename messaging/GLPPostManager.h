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

//extern NSInteger const kGLPNumberOfPosts;

+ (void)loadInitialPostsWithLocalCallback:(void (^)(NSArray *localPosts))localCallback remoteCallback:(void (^)(BOOL success, BOOL remain, NSArray *remotePosts))remoteCallback;
+(void)loadRemotePostsForUserRemoteKey:(int)remoteKey callback:(void (^)(BOOL success, NSArray *posts))callback;
+ (void)loadLocalPostsBefore:(GLPPost *)post callback:(void (^)(NSArray *posts))callback;
+ (void)loadRemotePostsBefore:(GLPPost *)post withNotUploadedPosts:(NSArray*)notUploadedPosts andCurrentPosts:(NSArray*)posts callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback;
+ (void)loadPreviousPostsAfter:(GLPPost *)post callback:(void (^)(BOOL success, BOOL remain, NSArray *posts))callback;
+(void)loadPostWithRemoteKey:(NSInteger)remoteKey callback:(void (^)(BOOL sucess, GLPPost* post))callback;
+ (void)createLocalPost:(GLPPost*)post;
+ (void)updatePostAfterSending:(GLPPost *)post;
+(void)updatePostWithLiked:(GLPPost*)post;
+(void)updatePostWithRemoteKey:(int)remoteKey andNumberOfComments:(int)numberOfComments;
+(void)loadEventsRemotePostsForUserRemoteKey:(int)remoteKey callback:(void (^)(BOOL success, NSArray *posts))callback;
+ (void)setFakeKeysToPrivateProfilePosts:(NSArray *)privateProfilePosts;
+ (void)setFakeKeyToPost:(GLPPost *)post;
+ (void)updatePostAttending:(GLPPost*)post;
+(void)deletePostWithPost:(GLPPost *)post;

@end
