//
//  GLPPostNotificationHelper.h
//  Gleepost
//
//  Created by Σιλουανός on 27/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"


@interface GLPPostNotificationHelper : NSObject

/**
 Parse notification and return the index in the table view controller needs to be updated.
 
 @param posts array contains all the posts.
 @return index the index of the post in table view.
 
 */
+(int)parseNotification:(NSNotification*)notification withPostsArray:(NSArray*)posts;

/**
 Sends a notification to the appropriate notification name.
 
 @param notificationName the name of the notification.
 @param object the sender object.
 @param remotekey post's remote key.
 @param likes number of likes.
 @param comments number of comments.
 
 */
+(void)updatePostWithNotifiationName:(NSString*)notificationName withObject:(id)object remoteKey:(int)remoteKey numberOfLikes:(int)likes andNumberOfComments:(int)comments;

+(int)parsePost:(GLPPost **)post imageNotification:(NSNotification*)notification withPostsArray:(NSArray*)posts;

+ (NSInteger)parsePostWithImageUrlNotification:(NSNotification *)notification withPostsArray:(NSArray *)posts;

+(int)parseLikedPostNotification:(NSNotification*)notification withPostsArray:(NSArray *)posts;

+(void)updatePostWithNotifiationName:(NSString*)notificationName withObject:(id)object remoteKey:(int)remoteKey withLiked:(BOOL)liked;

+(NSArray *)parseNotification:(NSNotification *)notification withPostsArrayForNewProfileImage:(NSArray *)posts;

+(int)parseNotificationAndFindIndexWithNotification:(NSNotification *)notification withPostsArray:(NSMutableArray *)posts;

+(void)deletePostNotificationWithPostRemoteKey:(int)remoteKey inCampusLive:(BOOL)postInCampusLive;

+ (NSInteger)findPostIndexWithKey:(NSInteger)key inPosts:(NSArray *)posts;

+ (NSInteger)findPostIndexWithRemoteKey:(NSInteger)remoteKey inPosts:(NSArray *)posts;

+ (NSInteger)parseRefreshCellNotification:(NSNotification *)notification withPostsArray:(NSArray *)posts;

@end
