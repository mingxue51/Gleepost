//
//  GLPContactDaoParser.m
//  Gleepost
//
//  Created by Σιλουανός on 31/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPContactDaoParser.h"
#import "GLPEntityDaoParser.h"
#import "GLPContact.h"

@implementation GLPContactDaoParser

+ (void)parseResultSet:(FMResultSet *)resultSet into:(GLPContact *)entity
{
    //[GLPEntityDaoParser parseResultSet:resultSet into:entity];
    entity.remoteKey = [resultSet intForColumn:GLPRemoteKeyColumn];

    entity.user = [[GLPUser alloc] init];
    entity.theyConfirmed = [resultSet boolForColumn:GLPContactTheyConfirmed];
    entity.youConfirmed = [resultSet boolForColumn:GLPContactYouConfirmed];
    
}

+ (GLPContact *)createContactFromResultSet:(FMResultSet *)resultSet
{
    GLPContact *user = [[GLPContact alloc] init];
    [GLPContactDaoParser parseResultSet:resultSet into:user];
    
    return user;
}

@end
