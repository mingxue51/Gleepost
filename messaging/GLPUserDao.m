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
    __block GLPUser *user = nil;
    
    [[DatabaseManager sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        user = [GLPUserDao findByRemoteKey:remoteKey db:db];
    }];
    
    return user;
}

+ (GLPUser *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from users where remoteKey=%d limit 1", remoteKey];
    
    GLPUser *user = nil;
    
    if([resultSet next]) {
        user = [GLPUserDaoParser createUserFromResultSet:resultSet];
    }
    
    return user;
}

+ (void)save:(GLPUser *)entity
{
    [[DatabaseManager sharedInstance].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdateWithFormat:@"insert into users(remoteKey, name) values(%d, %@)", entity.remoteKey, entity.name];
        
        entity.key = [db lastInsertRowId];
    }];
}

@end
