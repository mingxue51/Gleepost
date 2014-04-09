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

@interface GLPPostDao : NSObject

+ (NSArray *)findLastPostsInDb:(FMDatabase *)db;
+ (NSArray *)findLastPostsAfter:(GLPPost *)post inDb:(FMDatabase *)db;
+ (NSArray *)findAllPostsBefore:(GLPPost *)post inDb:(FMDatabase *)db;
+ (void)save:(GLPPost *)entity inDb:(FMDatabase *)db;
+ (void)updatePostSendingData:(GLPPost *)entity inDb:(FMDatabase *)db;
+ (void)deleteAllInDb:(FMDatabase *)db;
+(void)updateLikedStatusWithPost:(GLPPost*)entity inDb:(FMDatabase*)db;
+(void)updateCommentStatusWithNumberOfComments:(int)number andPostRemoteKey:(int)remoteKey inDb:(FMDatabase*)db;
+(NSArray*)likedPostsInDb:(FMDatabase*)db;
+(void)updatePostAttending:(GLPPost*)entity db:(FMDatabase *)db;
+(void)deletePostWithPost:(GLPPost *)entity db:(FMDatabase *)db;

@end
