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

+ (GLPUser *)findByKey:(NSInteger)key db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from users where key=%d limit 1", key];
    
    GLPUser *user = nil;
    
    if([resultSet next]) {
        user = [GLPUserDaoParser createUserFromResultSet:resultSet];
    }
    
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

//+(GLPUser*)loadUsersWithContactRemoteKey:(int)remoteKey db:(FMDatabase *)db
//{
//    GLPUser *user = [[GLPUser alloc] init];
//    
//    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from users where remoteKey=%d",remoteKey];
//    
//    while ([resultSet next])
//    {
//        [users addObject:[GLPContactDaoParser createContactFromResultSet:resultSet]];
//    }
//    
//    return users;
//}

/**
 At the moment just save.
 
 TODO: On request conversations not able to return more users' details. Fix this issue.
 
 @return user's database local id.
 
 */
+ (int)saveIfNotExist:(GLPUser*)entity db:(FMDatabase *)db
{
    //Find user by remote id. If user exist don't do anything. If not add new user.
    
    GLPUser *usr = [GLPUserDao findByRemoteKey:entity.remoteKey db:db];
    
    if(usr == nil)
    {
        //User doesn't exist, add user.
        
        [db executeUpdateWithFormat:@"insert into users(remoteKey, name, full_name, image_url, course, network_id, network_name, tagline, rsvp_count, group_count, post_count) values(%d, %@, %@, %@, %@, %d, %@, %@, %d, %d, %d)", entity.remoteKey, entity.name, entity.fullName, entity.profileImageUrl, entity.course, entity.networkId, entity.networkName, entity.personalMessage, [entity.rsvpCount intValue], [entity.groupCount intValue], [entity.postsCount intValue]];

        entity.key = [db lastInsertRowId];
        
        return entity.key;

    }
    
    return usr.key;
}



+ (void)save:(GLPUser *)entity inDb:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"insert into users(remoteKey, name, full_name, image_url, course, network_id, network_name, tagline, email, rsvp_count, group_count, post_count) values(%d, %@, %@, %@, %@, %d, %@, %@, %@, %d, %d, %d)", entity.remoteKey, entity.name, entity.fullName, entity.profileImageUrl, entity.course, entity.networkId, entity.networkName, entity.personalMessage, entity.email, [entity.rsvpCount intValue], [entity.groupCount intValue], [entity.postsCount intValue]];
    
    entity.key = [db lastInsertRowId];
}

+(void)saveOrUpdate
{
    //If the user exist update.
    
    //If the user not exist add user.
    
}

+(void)updateUserWithRemotKey:(int)remoteKey andProfileImage:(NSString*)imageUrl
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL b = [db executeUpdateWithFormat:@"update users set image_url=%@ where remoteKey=%d",
         imageUrl,
         remoteKey];
        
        NSLog(@"User's image saved with status: %d", b);
    }];
}

+(void)update:(GLPUser*)entity
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdateWithFormat:@"update users set name=%@, full_name=%@, image_url=%@, course=%@, network_id=%d, network_name=%@, tagline=%@, rsvp_count, group_count, post_count where remoteKey=%d",
         entity.name,
         entity.fullName,
         entity.profileImageUrl,
         entity.course,
         entity.networkId,
         entity.networkName,
         entity.personalMessage,
         entity.remoteKey,
         [entity.rsvpCount intValue],
         [entity.groupCount intValue],
         [entity.postsCount intValue]];
    }];
    
}

@end
