//
//  GLPGroupDao.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPGroup.h"

@class FMDatabase;

@interface GLPGroupDao : NSObject


+(void)saveGroups:(NSArray *)groups;
+(void)saveIfNotExist:(GLPGroup *)group;
+(void)remove:(GLPGroup *)group;
+(NSArray *)findGroups;
+(NSArray *)findRemoteGroups;
+ (GLPGroup *)findByRemoteKey:(int)remoteKey db:(FMDatabase *)db;
+(void)updateGroupSendingData:(GLPGroup *)entity;
+(void)updateGroup:(GLPGroup *)entity;


@end
