//
//  DatabaseManager.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DatabaseManager : NSObject

@property (strong, nonatomic) FMDatabase *database;

+ (DatabaseManager *)sharedInstance;

- (void)initDatabase;
- (void)dropDatabase;
- (void)closeDatabaseIfNeed;

@end
