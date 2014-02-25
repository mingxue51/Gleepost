//
//  GLPCommentDaoParser.h
//  Gleepost
//
//  Created by Silouanos on 25/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "GLPComment.h"

@interface GLPCommentDaoParser : NSObject

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPComment *)entity inDb:(FMDatabase *)db;
+ (GLPComment *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;

@end
