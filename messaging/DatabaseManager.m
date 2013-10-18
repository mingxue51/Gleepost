//
//  DatabaseManager.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "DatabaseManager.h"

@interface DatabaseManager()

@property (assign, nonatomic) BOOL exists;
@property (strong, nonatomic) NSString *path;

@end

@implementation DatabaseManager

@synthesize database = _database;

NSString * const GLPDatabaseName = @"Gleepost2.sqlite";

static DatabaseManager *instance = nil;

+ (DatabaseManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DatabaseManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    self.path = [docsPath stringByAppendingPathComponent:GLPDatabaseName];
    
    self.exists = [[NSFileManager defaultManager] fileExistsAtPath:self.path];
    
    return self;
}

- (void)initDatabase
{
    self.database = [FMDatabase databaseWithPath:self.path];
    [self.database open];
    
    if(!self.exists) {
        NSLog(@"create database");
        // user
        [self.database executeUpdate:@"create table users ( \
         key integer primary key autoincrement, \
         remoteKey integer, \
         name text);"];
        
        // conversation
        [self.database executeUpdate:@"create table conversations ( \
         key integer primary key autoincrement, \
         remoteKey integer, \
         lastMessage text, \
         lastUpdate integer, \
         title text);"];
        
        // message
        [self.database executeUpdate:@"create table messages ( \
         key integer primary key autoincrement, \
         remoteKey integer, \
         date integer, \
         content text, \
         sendStatus integer, \
         author_key integer, \
         conversation_key integer);"];
        
        self.exists = YES;
    }
}

- (void)dropDatabase
{
    [self closeDatabaseIfNeed];
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}

- (void)closeDatabaseIfNeed
{
    if(self.database.open) {
        [self.database close];
    }
}

@end
