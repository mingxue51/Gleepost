//
//  GLPMemberDaoParser.h
//  Gleepost
//
//  Created by Σιλουανός on 12/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

@class GLPMember;

@interface GLPMemberDaoParser : NSObject

+ (GLPMember *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db;

@end
