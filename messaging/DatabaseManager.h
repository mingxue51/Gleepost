//
//  DatabaseManager.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface DatabaseManager : NSObject

@property (readonly, strong, nonatomic) FMDatabaseQueue *databaseQueue;

+ (DatabaseManager *)sharedInstance;
+ (void)run:(void (^)(FMDatabase *db))block;
+ (void)transaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

- (void)initDatabase;
- (void)dropDatabase;

@end
