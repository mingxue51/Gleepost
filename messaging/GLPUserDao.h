//
//  GLPUserDao.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPUser.h"
#import "FMDatabase.h"

@interface GLPUserDao : NSObject

+ (GLPUser *)findByKey:(NSInteger)key db:(FMDatabase *)db;
+ (GLPUser *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db;
+ (void)save:(GLPUser *)entity inDb:(FMDatabase *)db;
+ (NSInteger)saveIfNotExist:(GLPUser*)entity db:(FMDatabase *)db;
+ (void)saveUsersIfNotExists:(NSArray *)users db:(FMDatabase *)db;
+ (void)updateLoggedInUsersName:(NSString *)name andSurname:(NSString *)surname;
+ (void)updateLoggedInUsersTagline:(NSString *)tagline;
+(void)update:(GLPUser*)entity;
+(void)updateUserWithRemotKey:(int)remoteKey andProfileImage:(NSString*)imageUrl;
@end
