//
//  GLPLiveUserDao.h
//  Gleepost
//
//  Created by Σιλουανός on 8/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPUser.h"
#import "FMDatabase.h"

@interface GLPLiveUserDao : NSObject

+ (GLPUser *)findByRemoteKey:(NSInteger)remoteKey;
+ (GLPUser *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db;
+ (void)save:(GLPUser *)entity;
+ (int)saveIfNotExist:(GLPUser*)entity db:(FMDatabase *)db;
+ (GLPUser *)findByKey:(NSInteger)key db:(FMDatabase *)db;
+(void)update:(GLPUser*)entity;

@end
