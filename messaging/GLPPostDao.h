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
+ (NSArray *)findLastPostsBefore:(GLPPost *)post inDb:(FMDatabase *)db;
+ (void)save:(GLPPost *)entity inDb:(FMDatabase *)db;

@end
