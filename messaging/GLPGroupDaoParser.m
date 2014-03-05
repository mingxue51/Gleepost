//
//  GLPGroupDaoParser.m
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPGroupDaoParser.h"
#import "GLPEntityDaoParser.h"

@implementation GLPGroupDaoParser

+ (GLPGroup *)parseResultSet:(FMResultSet *)resultSet into:(GLPGroup *)entity inDb:(FMDatabase *)db
{
    entity = [[GLPGroup alloc] init];
    
    entity.name = [resultSet stringForColumn:@"name"];
    entity.groupImageUrl = [resultSet stringForColumn:@"image_url"];
    entity.title = [resultSet stringForColumn:@"title"];
    entity.description = [resultSet stringForColumn:@"description"];
    
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    return entity;
}

+ (GLPGroup *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPGroup *group = nil;
    
    return [self parseResultSet:resultSet into:group inDb:db];
}

@end
