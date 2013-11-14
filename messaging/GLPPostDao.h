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

@end
