//
//  GLPMemberDaoParser.h
//  Gleepost
//
//  Created by Σιλουανός on 12/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPUser.h"
#import "FMResultSet.h"

@interface GLPMemberDaoParser : NSObject

+ (GLPUser *)parseResultSet:(FMResultSet *)resultSet into:(GLPUser *)entity inDb:(FMDatabase *)db;
+ (GLPUser *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;

@end
