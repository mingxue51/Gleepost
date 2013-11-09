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
@property (strong, nonatomic) FMDatabaseQueue *databaseQueue;

@end

@implementation DatabaseManager

@synthesize databaseQueue=_databaseQueue;

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

+ (void)transaction:(void (^)(FMDatabase *db, BOOL *rollback))block
{
    [[DatabaseManager sharedInstance].databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        db.traceExecution = NO;
        db.logsErrors = YES;

        block(db, rollback);
    }];
}

+ (void)run:(void (^)(FMDatabase *db))block
{
    [[DatabaseManager sharedInstance].databaseQueue inDatabase:^(FMDatabase *db) {
        db.traceExecution = NO;
        db.logsErrors = YES;
        
        block(db);
    }];
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
//    self.database = [FMDatabase databaseWithPath:self.path];
//    [self.database open];
    
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.path];
    
    if(!self.exists) {
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            NSLog(@"create database");
            
            // user
            [db executeUpdate:@"create table users ( \
             key integer primary key autoincrement, \
             remoteKey integer unique not null, \
             name text, \
             image_url text, \
             course text, \
             network_id integer, \
             network_name text, \
             tagline text);"];
            
            // contacts
            [db executeUpdate:@"create table contacts ( \
             remoteKey integer primary key, \
             you_confirmed interger, \
             they_confirmed integer);"];
            
            // conversation
            [db executeUpdate:@"create table conversations ( \
             key integer primary key autoincrement, \
             remoteKey integer unique not null, \
             lastMessage text, \
             lastUpdate integer, \
             title text, \
             unread integer, \
             isGroup integer);"];
            
            
            // live conversations
            [db executeUpdate:@"create table live_conversations ( \
             key integer primary key autoincrement, \
             remoteKey integer unique not null, \
             lastUpdate integer, \
             title text, \
             unread integer, \
             timeStarted integer);"];
            
            // message
            [db executeUpdate:@"create table messages ( \
             key integer primary key autoincrement, \
             remoteKey integer unique not null, \
             date integer, \
             content text, \
             sendStatus integer, \
             seen integer, \
             isOld integer, \
             author_key integer, \
             conversation_key integer);"];
            
            // conversation participants
            [db executeUpdate:@"create table conversations_participants ( \
             user_key integer, \
             conversation_key integer);"];
            
            // message participants
            [db executeUpdate:@"create table messages_participants ( \
             user_key integer, \
             message_key integer);"];
            
            self.exists = YES;
        }];
    }
}

- (void)dropDatabase
{
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}


@end
