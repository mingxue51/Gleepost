//
//  GLPMemberDaoParser.m
//  Gleepost
//
//  Created by Σιλουανός on 12/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMemberDaoParser.h"
#import "GLPEntityDaoParser.h"
#import "GLPMember.h"

@implementation GLPMemberDaoParser

+ (GLPMember *)parseResultSet:(FMResultSet *)resultSet into:(GLPMember *)entity inDb:(FMDatabase *)db
{
    entity = [[GLPMember alloc] initWithName:[resultSet stringForColumn:@"name"] withGroupRemoteKey:[resultSet intForColumn:@"group_remote_key"] imageUrl:[resultSet stringForColumn:@"image_url"] andRoleLevelNumber:[resultSet intForColumn:@"roleKey"]];
    
//    entity.name = [resultSet stringForColumn:@"name"];
//    entity.profileImageUrl = [resultSet stringForColumn:@"image_url"];
//    entity.networkId = [resultSet intForColumn:@"group_remote_key"];
    
    
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    return entity;
}

+ (GLPMember *)createFromResultSet:(FMResultSet *)resultSet inDb:(FMDatabase *)db
{
    GLPMember *member = nil;
    
    return [self parseResultSet:resultSet into:member inDb:db];
}

@end
