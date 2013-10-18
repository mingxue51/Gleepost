//
//  GLPUserDaoParser.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPUser.h"
#import "FMResultSet.h"

@interface GLPUserDaoParser : NSObject

+ (GLPUser *)createUserFromResultSet:(FMResultSet *)resultSet;
+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPUser *)entity;

@end
