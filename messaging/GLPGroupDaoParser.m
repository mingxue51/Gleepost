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
    
    entity.name = [resultSet stringForColumn:@"title"];
    entity.groupImageUrl = [resultSet stringForColumn:@"image_url"];
    entity.groupDescription = [resultSet stringForColumn:@"description"];
    entity.sendStatus = [resultSet intForColumn:@"send_status"];
    
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    return entity;
}

+ (GLPGroup *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPGroup *group = nil;
    
    return [self parseResultSet:resultSet into:group inDb:db];
}

@end
