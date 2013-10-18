//
//  GLPMessageDaoParser.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "GLPMessage.h"

@interface GLPMessageDaoParser : NSObject

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPMessage *)entity;
+ (GLPMessage *)createFromResultSet:(FMResultSet *)resultSet;

@end
