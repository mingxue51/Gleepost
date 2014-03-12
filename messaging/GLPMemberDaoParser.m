//
//  GLPMemberDaoParser.m
//  Gleepost
//
//  Created by Σιλουανός on 12/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMemberDaoParser.h"
#import "GLPEntityDaoParser.h"

@implementation GLPMemberDaoParser

+ (GLPUser *)parseResultSet:(FMResultSet *)resultSet into:(GLPUser *)entity inDb:(FMDatabase *)db
{
    entity = [[GLPUser alloc] init];
    
    entity.name = [resultSet stringForColumn:@"name"];
    entity.profileImageUrl = [resultSet stringForColumn:@"image_url"];
    entity.networkId = [resultSet intForColumn:@"group_remote_key"];
    
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    return entity;
}

+ (GLPUser *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPUser *member = nil;
    
    return [self parseResultSet:resultSet into:member inDb:db];
}

@end
