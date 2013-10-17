//
//  SessionManager.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "SessionManager.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "DateFormatterHelper.h"

@interface SessionManager()

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) GLPUser *user;
@property (strong, nonatomic) NSString *dataPlistPath;
@property (strong, nonatomic) NSMutableDictionary *data;

@property (strong, nonatomic) NSDictionary *authParameters;

@end


@implementation SessionManager

@synthesize token = _token;
@synthesize user = _user;
@synthesize authParameters = _authParameters;

NSString * const GLPSessionFileName = @"GLPSession.plist";

static SessionManager *instance = nil;

+ (SessionManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SessionManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    // init plist path
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.dataPlistPath = [rootPath stringByAppendingPathComponent:GLPSessionFileName];
    
    [self loadData];
    
    return self;
}

- (void)registerUserWithRemoteKey:(NSInteger)remoteKey token:(NSString *)token andExpirationDate:(NSDate *)expirationDate
{
    if(self.user) {
        [NSException raise:@"Invalid register new user while another already exists" format:@"User %@", self.user];
    }
    
    // (drop previous if need and) create database
    [DatabaseManager dropDatabase];
    [DatabaseManager createDatabase];
    
    // configure session
    self.user = [UserManager getOrCreateUserForRemoteKey:remoteKey];
    self.token = token;
    self.authParameters = @{@"id": [NSString stringWithFormat:@"%d", remoteKey], @"token": token};
    
    // save session
    self.data[@"user.remoteKey"] = self.user.remoteKey;
    self.data[@"user.token"] = self.token;
    self.data[@"user.expirationDate"] = [[DateFormatterHelper createDefaultDateFormatter] stringFromDate:expirationDate];
    
    [self saveData];
}

- (void)cleanSession
{
    self.user = nil;
    self.token = nil;
    self.authParameters = nil;
    
    [self.data removeAllObjects];
    [self saveData];
}


- (void)logout
{
    [self cleanSession];
    [DatabaseManager dropDatabase];
}

- (BOOL)isSessionValid
{
    // check token expiration
    if(self.data[@"user.token"]) {
        NSDate *expirationDate = [[DateFormatterHelper createDefaultDateFormatter] dateFromString:self.data[@"user.expirationDate"]];
        
        // expired
        if([[NSDate date] compare:expirationDate] == NSOrderedAscending) {
            return YES;
        }
    }
    
    return NO;
}

- (void)loadData
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataPlistPath] == YES) {
        self.data = [NSMutableDictionary dictionaryWithContentsOfFile:self.dataPlistPath];
        
        if([self isSessionValid]) {
            [DatabaseManager createDatabase];
            self.user = [UserManager getUserForRemoteKey:[self.data[@"user.remoteKey"] integerValue]];
            self.token = self.data[@"user.token"];
            self.authParameters = @{@"id": [NSString stringWithFormat:@"%@", self.user.remoteKey], @"token": self.token};
        } else { // clean expired session
            [self cleanSession];
        }
        
    } else {
        self.data = [NSMutableDictionary dictionary];
    }
}

- (void)saveData
{
    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:self.data
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    
    if(plistData) {
        [plistData writeToFile:self.dataPlistPath atomically:YES];
    } else {
        [NSException raise:@"Save session data error" format:@"Error: %@", error];
    }
}



@end
