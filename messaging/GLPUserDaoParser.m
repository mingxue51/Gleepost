//
//  GLPUserDaoParser.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPUserDaoParser.h"
#import "GLPEntityDaoParser.h"
#import "GLPUser.h"

@implementation GLPUserDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPUser *)entity
{
    [GLPEntityDaoParser parseResultSet:resultSet into:entity];
    
    entity.name = [resultSet stringForColumn:@"name"];
    entity.profileImageUrl = [resultSet stringForColumn:@"image_url"];
    entity.course = [resultSet stringForColumn:@"course"];
    entity.networkId = [resultSet intForColumn:@"network_id"];
    entity.networkName = [resultSet stringForColumn:@"network_name"];
    entity.personalMessage = [resultSet stringForColumn:@"tagline"];
}

+ (GLPUser *)createUserFromResultSet:(FMResultSet *)resultSet
{
    GLPUser *user = [[GLPUser alloc] init];
    [GLPUserDaoParser parseResultSet:resultSet into:user];
    
    return user;
}

@end
