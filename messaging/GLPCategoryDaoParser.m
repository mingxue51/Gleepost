//
//  GLPCategoryDaoParser.m
//  Gleepost
//
//  Created by Silouanos on 21/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPCategoryDaoParser.h"
#import "GLPEntityDaoParser.h"

@implementation GLPCategoryDaoParser

+ (GLPCategory*)parseResultSet:(FMResultSet *)resultSet into:(GLPCategory *)entity inDb:(FMDatabase *)db
{
    entity = [[GLPCategory alloc] initWithTag:[resultSet stringForColumn:@"tag"] name:[resultSet stringForColumn:@"name"] andPostRemoteKey:[resultSet intForColumn:@"post_remote_key"]];
    
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    return entity;
}

+ (GLPCategory *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPCategory *category = nil;
    
    return [self parseResultSet:resultSet into:category inDb:db];
}

@end
