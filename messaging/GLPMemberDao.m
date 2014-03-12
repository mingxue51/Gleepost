//
//  GLPMemberDao.m
//  Gleepost
//
//  Created by Σιλουανός on 12/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMemberDao.h"
#import "GLPMemberDaoParser.h"

@implementation GLPMemberDao


+ (GLPUser *)findMember:(GLPUser *)entity db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from members where group_remote_key=%d AND remoteKey=%d", entity.networkId, entity.remoteKey];
    
    GLPUser *member = nil;
    
    if([resultSet next]) {
        
        member = [GLPMemberDaoParser createFromResultSet:resultSet inDb:db];
    }
    
    return member;
}

+(NSArray *)findMembersWithGroupRemoteKey:(int)groupRemoteKey db:(FMDatabase *)db
{
    NSMutableArray *members = [[NSMutableArray alloc] init];
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from members where group_remote_key = %d", groupRemoteKey];
    
    while ([resultSet next])
    {
        GLPUser *currentMember = [GLPMemberDaoParser createFromResultSet:resultSet inDb:db];
        
        [members addObject: currentMember];
        
    }
    
    return members;
}

+(NSArray *)findMembersWithGroupRemoteKey:(int)groupRemoteKey
{
    __block NSArray *members = [[NSMutableArray alloc] init];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        members = [GLPMemberDao findMembersWithGroupRemoteKey:groupRemoteKey db:db];
        
    }];
    
    return members;
}

/**
 Save member if member not exist with the current group remote key.
 
 @param entity
 @param db
 
 */

+(int)saveMemberIfNotExist:(GLPUser *)entity db:(FMDatabase *)db
{
    GLPUser *member = [GLPMemberDao findMember:entity db:db];
    
    if(member == nil)
    {
        [GLPMemberDao save:entity inDb:db];
        entity.key = [db lastInsertRowId];
        
        return entity.key;
    }
    
    return member.key;
}

+(void)save:(GLPUser *)entity inDb:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"insert into members (remoteKey, name, image_url, group_remote_key) values(%d, %@, %@, %d)",
     entity.remoteKey,
     entity.name,
     entity.profileImageUrl,
     entity.networkId];


    entity.key = [db lastInsertRowId];
}

+(void)saveMembers:(NSArray *)members
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        for(GLPUser *member in members)
        {
            member.key = [GLPMemberDao saveMemberIfNotExist:member db:db];
        }
        
    }];
}

@end
