//
//  GLPEntityDaoParser.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPEntity.h"
#import "FMResultSet.h"

@interface GLPEntityDaoParser : NSObject

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPEntity *)entity;

@end
