//
//  GLPMemberDao.h
//  Gleepost
//
//  Created by Σιλουανός on 12/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"

@class GLPMember;

@interface GLPMemberDao : NSObject

+ (NSArray *)findMembersWithGroupRemoteKey:(int)groupRemoteKey;
+ (GLPMember *)findMemberWithRemoteKey:(NSInteger)memberRemoteKey withGroupRemoteKey:(NSInteger)groupRemoteKey andDb:(FMDatabase *)db;
+ (void)addMemberAsAdministrator:(GLPMember *)member;
+ (void)removeMemberFromAdministrator:(GLPMember *)member;
+ (void)removeMember:(GLPMember *)member withGroupRemoteKey:(NSInteger)groupRemoteKey;
+ (void)saveMembers:(NSArray *)members withGroupRemoteKey:(NSInteger)groupRemoteKey;

@end
