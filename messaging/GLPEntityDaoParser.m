//
//  GLPEntityDaoParser.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPEntityDaoParser.h"

@implementation GLPEntityDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPEntity *)entity
{
    entity.key = [resultSet intForColumn:GLPKeyColumn];
    entity.remoteKey = [resultSet intForColumn:GLPRemoteKeyColumn];
}

@end
