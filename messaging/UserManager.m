//
//  UserManager.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "UserManager.h"
#import "GLPUserDao.h"
#import "DatabaseManager.h"

@implementation UserManager

+ (GLPUser *)getUserForRemoteKey:(NSInteger)remoteKey
{
    __block GLPUser *user = nil;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        user = [GLPUserDao findByRemoteKey:remoteKey db:db];
    
    }];
    
    
    return user;
}

//+ (GLPUser *)getUserForRemoteKey:(NSInteger)remoteKey
//{
//    GLPUser *user = [GLPUser MR_findFirstByAttribute:@"remoteKey" withValue:[NSNumber numberWithInteger:remoteKey]];
//    
//    if(!user) {
//        [NSException raise:@"User not found" format:@"For remote key %d", remoteKey];
//    }
//    
//    return user;
//}



//+ (GLPUser *)getOrCreateUserForRemoteKey:(NSInteger)remoteKey
//{
//    GLPUser *user = [GLPUser MR_findFirstByAttribute:@"remoteKey" withValue:[NSNumber numberWithInteger:remoteKey]];
//    
//    if(!user) {
//        user = [GLPUser MR_createEntity];
//        user.remoteKeyValue = remoteKey;
//        
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//    }
//    
//    return user;
//}

@end
