//
//  GLPMessageDaoParser.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "FMDatabase.h"
#import "GLPMessage.h"

@interface GLPMessageDaoParser : NSObject

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPMessage *)entity db:(FMDatabase *)db;
+ (GLPMessage *)createFromResultSet:(FMResultSet *)resultSet db:(FMDatabase *)db;

@end
