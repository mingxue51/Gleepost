//
//  GLPCategoryDaoParser.h
//  Gleepost
//
//  Created by Silouanos on 21/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "GLPCategory.h"

@interface GLPCategoryDaoParser : NSObject

+ (GLPCategory*)parseResultSet:(FMResultSet *)resultSet into:(GLPCategory *)entity inDb:(FMDatabase *)db;
+ (GLPCategory *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;

@end
