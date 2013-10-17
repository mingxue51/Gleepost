//
//  DatabaseManager.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "DatabaseManager.h"

@implementation DatabaseManager

NSString * const GLPDatabaseName = @"Gleepost.sqlite";

+ (void)createDatabase
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Gleepost.sqlite"];
}

+ (void)dropDatabase
{
    [MagicalRecord cleanUp];
    
    NSError *error = nil;
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:GLPDatabaseName];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
}

@end
