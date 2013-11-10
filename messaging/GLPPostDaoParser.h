//
//  GLPPostDaoParser.h
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPPost.h"
#import "FMDatabase.h"

@interface GLPPostDaoParser : NSObject

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPPost *)entity inDb:(FMDatabase *)db;
+ (GLPPost *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;

@end
