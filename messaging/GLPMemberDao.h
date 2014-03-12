//
//  GLPMemberDao.h
//  Gleepost
//
//  Created by Σιλουανός on 12/3/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"

@interface GLPMemberDao : NSObject

+(NSArray *)findMembersWithGroupRemoteKey:(int)groupRemoteKey;
+(void)saveMembers:(NSArray *)members;

@end
