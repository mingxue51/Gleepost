//
//  DatabaseManager.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//
//  Note on DB scheme:
//  Foreign keys are always created using remote keys fields

#import "DatabaseManager.h"

@interface DatabaseManager()

@property (assign, nonatomic) BOOL exists;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) FMDatabaseQueue *databaseQueue;

@end

@implementation DatabaseManager

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
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.path];
    
    if(!self.exists) {
        [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            DDLogInfo(@"create database");
            
            // user
            [db executeUpdate:@"create table users ( \
             key integer primary key autoincrement, \
             remoteKey integer unique not null, \
             name text, \
             full_name text, \
             image_url text, \
             course text, \
             network_id integer, \
             network_name text, \
             tagline text, \
             email text, \
             rsvp_count integer, \
             group_count integer, \
             post_count integer);"]; //e-mail is used for now just for the logged in user.
            
            // contacts
            [db executeUpdate:@"create table contacts ( \
             remoteKey integer primary key, \
             you_confirmed interger, \
             they_confirmed integer, \
             name text);"];
            
            // conversation
            [db executeUpdate:@"create table conversations ( \
             key integer primary key autoincrement, \
             remoteKey integer unique not null, \
             lastMessage text, \
             lastUpdate integer, \
             title text, \
             participants_keys text, \
             unread integer, \
             isGroup integer, \
             isLive integer);"];
            
            
            // live conversations
            [db executeUpdate:@"create table live_conversations ( \
             key integer primary key autoincrement, \
             remoteKey integer unique not null, \
             lastUpdate integer, \
             title text, \
             unread integer, \
             timeStarted integer);"];
            
            // live conversations participants
            [db executeUpdate:@"create table live_conversations_participants ( \
             live_user_key integer, \
             live_conversation_key integer);"];
            
            // live users
            [db executeUpdate:@"create table live_users ( \
             key integer primary key autoincrement, \
             remoteKey integer, \
             name text, \
             image_url text, \
             course text, \
             network_id integer, \
             network_name text, \
             tagline text);"];
            
            // message
            [db executeUpdate:@"create table messages ( \
             key integer primary key autoincrement, \
             remoteKey integer unique, \
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
            
            // post
            [db executeUpdate:@"create table posts ( \
             key integer primary key autoincrement, \
             remoteKey integer unique, \
             date integer, \
             content text, \
             likes integer, \
             dislikes integer, \
             comments integer, \
             sendStatus integer, \
             author_key integer, \
             liked integer, \
             event_title text, \
             event_date integer, \
             attending integer, \
             location_lat real, \
             location_lon real, \
             location_name text, \
             location_address text);"];
            
            // post images
            [db executeUpdate:@"create table post_images ( \
             post_remote_key integer, \
             image_url text);"];
            
            // post videos
            [db executeUpdate:@"create table post_videos ( \
             post_remote_key integer, \
             post_key integer primary key, \
             video_url text, \
             video_thumbnail_url text, \
             video_temp_key integer);"];
            
            // categories
            [db executeUpdate:@"create table categories ( \
             key integer primary key autoincrement, \
             remoteKey integer, \
             post_remote_key integer, \
             tag text, \
             name text);"];
            
            // notifications
            [db executeUpdate:@"create table notifications ( \
             key integer primary key autoincrement, \
             remoteKey integer unique not null, \
             seen integer, \
             date integer, \
             type integer, \
             post_remote_key integer, \
             user_remote_key integer, \
             group_remote_key integer);"];
            
            // comments
            [db executeUpdate:@"create table comments ( \
             key integer primary key autoincrement, \
             remoteKey integer unique, \
             post_remote_key integer, \
             content text, \
             date integer, \
             send_status integer, \
             user_remote_key integer, \
             image_url text);"]; //Image url is for future use.
            
            // groups
            [db executeUpdate:@"create table groups ( \
             key integer primary key autoincrement, \
             remoteKey integer unique, \
             title text, \
             description text, \
             image_url text, \
             send_status integer, \
             date integer, \
             user_remote_key integer, \
             privacy integer);"];
            
            // group members
            [db executeUpdate:@"create table members ( \
             key integer primary key autoincrement, \
             remoteKey integer, \
             name text, \
             image_url text, \
             group_remote_key integer);"];
            
            self.exists = YES;
        }];
    }
}

- (void)dropDatabase
{
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    self.exists = NO;
}


@end
