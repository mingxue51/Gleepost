//
//  GLPUserDaoParser.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPUserDaoParser.h"
#import "GLPEntityDaoParser.h"

@implementation GLPUserDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPUser *)entity
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.name = [resultSet stringForColumn:GLPUserNameColumn];
    entity.profileImageUrl = [resultSet stringForColumn:GLPUserProfileImageColumn];
    entity.course = [resultSet stringForColumn:GLPUserCourseColumn];
    entity.networkId = [resultSet intForColumn:GLPUserNetworkIdColumn];
    entity.networkName = [resultSet stringForColumn:GLPUserNetworkNameColumn];
    entity.personalMessage = [resultSet stringForColumn:GLPUserPersonalMessageColumn];
}

+ (GLPUser *)createUserFromResultSet:(FMResultSet *)resultSet
{
    GLPUser *user = [[GLPUser alloc] init];
    [GLPUserDaoParser parseResultSet:resultSet into:user];
    
    return user;
}

@end
