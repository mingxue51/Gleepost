//
//  GLPPostDao.h
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"
#import "FMDatabase.h"

typedef NS_ENUM(NSUInteger, KindOfQuery) {
    kProfileQuery,
    kCampusWallQuery,
    kGroupQuery
};

@interface GLPPostDao : NSObject

+ (NSArray *)findLastPostsInDb:(FMDatabase *)db;
+ (NSArray *)findLastPostsAfter:(GLPPost *)post inDb:(FMDatabase *)db;
+ (NSArray *)findAllPostsBefore:(GLPPost *)post inDb:(FMDatabase *)db;
+ (NSArray *)findPostsWithUsersRemoteKey:(NSInteger)usersRemoteKey;
+ (NSArray *)findPostsWithUsersRemoteKey:(NSInteger)usersRemoteKey inDb:(FMDatabase *)db;
+ (NSArray *)findPostsInGroupWithRemoteKey:(NSInteger)groupRemoteKey inDb:(FMDatabase *)db;
+ (NSInteger)findPostKeyByRemoteKey:(NSInteger)remoteKey inDB:(FMDatabase *)db;
+ (NSArray *)loadPendingPosts;
+ (NSArray *)findAllPendingPostsWithVideosInDb:(FMDatabase *)db;
+ (void)save:(GLPPost *)entity inDb:(FMDatabase *)db;
+ (void)saveUpdateOrRemovePosts:(NSArray *)posts withCreatorRemoteKey:(NSInteger)userRemoteKey;
+ (void)saveUpdateOrRemovePosts:(NSArray *)posts withGroupRemoteKey:(NSInteger)groupRemoteKey;
+ (NSArray *)getTheNewPostsWithRemotePosts:(NSArray *)remotePosts;
+ (NSArray *)saveUpdateOrRemovePostsInCW:(NSArray *)posts;
+ (void)saveOrUpdatePost:(GLPPost *)entity;
+ (void)updatePostSendingData:(GLPPost *)entity inDb:(FMDatabase *)db;
+ (void)deleteAllInDb:(FMDatabase *)db;
+(void)updateLikedStatusWithPost:(GLPPost*)entity inDb:(FMDatabase*)db;
+(void)updateCommentStatusWithNumberOfComments:(int)number andPostRemoteKey:(int)remoteKey inDb:(FMDatabase*)db;
+(NSArray*)likedPostsInDb:(FMDatabase*)db;
+(void)updatePostAttending:(GLPPost*)entity db:(FMDatabase *)db;
+ (void)updatePendingStatuswithPost:(GLPPost *)entity;
+ (void)updateVideoPostSendingData:(GLPPost *)entity inDb:(FMDatabase *)db;
+(void)deletePostWithPost:(GLPPost *)entity db:(FMDatabase *)db;
+ (void)deletePostsWithGroupRemoteKey:(NSInteger)groupRemoteKey db:(FMDatabase *)db;
+ (void)updateImagesWithEntity:(GLPPost *)entity db:(FMDatabase *)db;

@end
