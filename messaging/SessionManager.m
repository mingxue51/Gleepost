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
#import "GLPUserDao.h"
#import "WebClient.h"

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

- (void)registerUser:(GLPUser *)user withToken:(NSString *)token andExpirationDate:(NSDate *)expirationDate
{
    NSAssert(!self.user, @"An user is already registered in the session");

    [[DatabaseManager sharedInstance] initDatabase];
    
    self.user = user;
    self.token = token;
    self.authParameters = @{@"id": [NSString stringWithFormat:@"%d", user.remoteKey], @"token": token};
    
    // save session
    self.data[@"user.remoteKey"] = [NSNumber numberWithInteger:self.user.remoteKey];
    self.data[@"user.name"] = self.user.name;
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
    [[DatabaseManager sharedInstance] dropDatabase];
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
    // load dictionnary data from saved file or create new one
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataPlistPath] == YES) {
        self.data = [NSMutableDictionary dictionaryWithContentsOfFile:self.dataPlistPath];
        
        if([self isSessionValid]) {
            [[DatabaseManager sharedInstance] initDatabase];
            self.user = [GLPUserDao findByRemoteKey:[self.data[@"user.remoteKey"] integerValue]];
            NSAssert(self.user, @"User from valid session must exist in database");
            
            self.token = self.data[@"user.token"];
            self.authParameters = @{@"id": [NSString stringWithFormat:@"%d", self.user.remoteKey], @"token": self.token};
        } else { // clean expired session
            [self cleanSession];
            [[DatabaseManager sharedInstance] dropDatabase];
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
