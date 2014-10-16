//
//  GLPMemberDao.m
//  Gleepost
//
//  Created by Σιλουανός on 12/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMemberDao.h"
#import "GLPMemberDaoParser.h"
#import "GLPMember.h"

@implementation GLPMemberDao


+ (GLPMember *)findMember:(GLPMember *)entity db:(FMDatabase *)db
{
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from members where group_remote_key=%d AND remoteKey=%d", entity.groupRemoteKey, entity.remoteKey];
    
    GLPMember *member = nil;
    
    if([resultSet next]) {
        
        member = [GLPMemberDaoParser createFromResultSet:resultSet inDb:db];
    }
    
    DDLogDebug(@"Find member %d", [db hasOpenResultSets]);
    
    return member;
}

+(NSArray *)findMembersWithGroupRemoteKey:(int)groupRemoteKey db:(FMDatabase *)db
{
    NSMutableArray *members = [[NSMutableArray alloc] init];
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from members where group_remote_key = %d order by name asc", groupRemoteKey];
    
    while ([resultSet next])
    {
        GLPMember *currentMember = [GLPMemberDaoParser createFromResultSet:resultSet inDb:db];
        
        [members addObject: currentMember];
        
    }
    
    DDLogDebug(@"findMembersWithGroupRemoteKey %d", [db hasOpenResultSets]);

    
    return members;
}

+ (GLPMember *)findMemberWithRemoteKey:(NSInteger)memberRemoteKey withGroupRemoteKey:(NSInteger)groupRemoteKey andDb:(FMDatabase *)db
{
    GLPMember *member = nil;
    
    GLPMember *searchedMember = [[GLPMember alloc] init];
    
    searchedMember.groupRemoteKey = groupRemoteKey;
    searchedMember.remoteKey = memberRemoteKey;
    
    member = [GLPMemberDao findMember:searchedMember db:db];
    
    if(!member)
    {
        member = searchedMember;
    }
    
    return member;
}

+(NSArray *)findMembersWithGroupRemoteKey:(int)groupRemoteKey
{
    __block NSArray *members = [[NSMutableArray alloc] init];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        members = [GLPMemberDao findMembersWithGroupRemoteKey:groupRemoteKey db:db];
        
    }];
    
    return members;
}

+ (void)addMemberAsAdministrator:(GLPMember *)member
{
    __block BOOL success = NO;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
     
        success = [db executeUpdateWithFormat:@"update members set roleKey=%d where remoteKey=%d",
                   kAdministrator,
                   member.remoteKey];
        
        
        DDLogInfo(@"Member %@ : %@ updated successfully %d", member.name, member.roleName, success);
        
    }];
}

+ (void)removeMemberFromAdministrator:(GLPMember *)member
{
    __block BOOL success = NO;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        success = [db executeUpdateWithFormat:@"update members set roleKey=%d where remoteKey=%d",
                   kMember,
                   member.remoteKey];
        
        
        DDLogInfo(@"Member %@ : %@ updated successfully %d", member.name, member.roleName, success);
        
    }];
}

/**
 Save member if member not exist with the current group remote key.
 
 @param entity
 @param db
 
 */

+(int)saveMemberIfNotExist:(GLPMember *)entity db:(FMDatabase *)db
{
    GLPMember *member = [GLPMemberDao findMember:entity db:db];
    
    if(member == nil)
    {
        [GLPMemberDao save:entity inDb:db];
        entity.key = [db lastInsertRowId];
        
        return entity.key;
    }
    
    return member.key;
}

+(void)save:(GLPMember *)entity inDb:(FMDatabase *)db
{
    [db executeUpdateWithFormat:@"insert into members (remoteKey, name, image_url, group_remote_key, roleKey) values(%d, %@, %@, %d, %d)",
     entity.remoteKey,
     entity.name,
     entity.profileImageUrl,
     entity.groupRemoteKey,
     entity.roleLevel];


    entity.key = [db lastInsertRowId];
}

+(void)saveMembers:(NSArray *)members
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        //Remove all elements from database.
//        [self removeAllTheEntriesInDb:db];
        
        for(GLPMember *member in members)
        {
            member.key = [GLPMemberDao saveMemberIfNotExist:member db:db];
        }
        
    }];
}

+(void)removeAllTheEntriesInDb:(FMDatabase*)db
{
    BOOL removed = [db executeUpdateWithFormat:@"delete from members"];
    
    DDLogDebug(@"All the members list removed %d.", removed);
}

@end
