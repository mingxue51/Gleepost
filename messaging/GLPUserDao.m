//
//  GLPUserDao.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPUserDao.h"
#import "DatabaseManager.h"
#import "GLPUserDaoParser.h"
#import "FMResultSet.h"

@implementation GLPUserDao

+ (GLPUser *)findByRemoteKey:(NSInteger)remoteKey
{
    FMResultSet *resultSet = [[DatabaseManager sharedInstance].database executeQueryWithFormat:@"select * from users where remoteKey=%d limit 1", remoteKey];
    
    if([resultSet next]) {
        return [GLPUserDaoParser createUserFromResultSet:resultSet];
    }
    
    return nil;
}

+ (void)save:(GLPUser *)entity
{
    [[DatabaseManager sharedInstance].database executeUpdateWithFormat:@"insert into users(remoteKey, name) values(%d, %@)", entity.remoteKey, entity.name];

    entity.key = [[DatabaseManager sharedInstance].database lastInsertRowId];
}

@end
