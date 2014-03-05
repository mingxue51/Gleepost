//
//  GLPGroupDaoParser.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "GLPGroup.h"

@interface GLPGroupDaoParser : NSObject

+ (GLPGroup *)parseResultSet:(FMResultSet *)resultSet into:(GLPGroup *)entity inDb:(FMDatabase *)db;
+ (GLPGroup *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;

@end
