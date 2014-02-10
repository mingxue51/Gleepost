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
#import "GLPThemeManager.h"

@interface SessionManager()

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) GLPUser *user;
@property (strong, nonatomic) NSString *dataPlistPath;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSString *pushToken;
@property (assign, nonatomic) BOOL pushTokenRegistered;
@property (strong, nonatomic) NSDictionary *authParameters;


@end


@implementation SessionManager

@synthesize token = _token;
@synthesize user = _user;
@synthesize authParameters = _authParameters;
@synthesize pushToken=_pushToken;
@synthesize pushTokenRegistered=_pushTokenRegistered;
@synthesize currentCategory = _currentCategory;

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
    
    _pushTokenRegistered = NO;
    _authParameters = [NSDictionary dictionary];
    
    //Set default category.
    _currentCategory = nil;
    
    
    [self loadData];
    
    return self;
}

- (void)registerUser:(GLPUser *)user withToken:(NSString *)token andExpirationDate:(NSDate *)expirationDate
{
    NSAssert(!self.user, @"An user is already registered in the session");
    
    self.user = user;
    self.token = token;
    self.authParameters = @{@"id": [NSString stringWithFormat:@"%d", user.remoteKey], @"token": token};
    
    // save session
    self.data[@"user.remoteKey"] = [NSNumber numberWithInteger:self.user.remoteKey];
    self.data[@"user.name"] = self.user.name;
    self.data[@"user.token"] = self.token;
    self.data[@"user.expirationDate"] = [[DateFormatterHelper createDefaultDateFormatter] stringFromDate:expirationDate];
    
    [self saveData];

    // register push if ready
    if(_pushToken && !_pushTokenRegistered) {
        [self registerPushOnServer];
    }
}

- (void)cleanSession
{
    self.user = nil;
    self.token = nil;
    self.authParameters = nil;
    
    [self.data removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtPath:self.dataPlistPath error:nil];
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

- (BOOL)isLogged
{
    return _user != nil;
}

- (NSUInteger)validUserRemoteKey
{
    if(![self isSessionValid] || !self.data[@"user.remoteKey"]) {
        return NSNotFound;
    }
    
    return [self.data[@"user.remoteKey"] intValue];
}

- (void)restoreUser:(GLPUser *)user
{
    _user = user;
    _token = self.data[@"user.token"];
    _authParameters = @{@"id": [NSString stringWithFormat:@"%d", self.user.remoteKey], @"token": self.token};
}

- (void)loadData
{
    // load dictionnary data from saved file or create new one
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataPlistPath] == YES) {
        self.data = [NSMutableDictionary dictionaryWithContentsOfFile:self.dataPlistPath];
        
        DDLogDebug(@"DATA: %@", self.data);
        
//        if([self isSessionValid]) {
//            [[DatabaseManager sharedInstance] initDatabase];
//            
//            __block GLPUser *user;
//            [DatabaseManager run:^(FMDatabase *db) {
//                user = [GLPUserDao findByRemoteKey:[self.data[@"user.remoteKey"] integerValue] db:db];
//            }];
//            self.user = user;
//            //Set theme depending on the network name.
//            [[GLPThemeManager sharedInstance] setNetwork:user.networkName];
//            
//            NSAssert(self.user, @"User from valid session must exist in database");
//            
//            self.token = self.data[@"user.token"];
//            self.authParameters = @{@"id": [NSString stringWithFormat:@"%d", self.user.remoteKey], @"token": self.token};
//        } else { // clean expired session
//            [self cleanSession];
//            [[DatabaseManager sharedInstance] dropDatabase];
//        }
        
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

#pragma mark - Push token

- (void)registerPushToken:(NSData *)token
{
    // convert from base64 to string
    const unsigned *tokenBytes = [token bytes];
    self.pushToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    //Add token to the plist file.
    self.data[@"user.pushToken"] = self.pushToken;
    
    DDLogInfo(@"Push Token: %@", self.data[@"user.pushToken"]);
    
    [self saveData];
    
    // register to the server if user is logged in, otherwise wait for the login
    if(self.user) {
        [self registerPushOnServer];
    }
}

- (void)registerPushOnServer
{
    // do not register twice
    if(_pushTokenRegistered) {
        return;
    }
    
    NSAssert(self.pushToken, @"Push token to register on server is null");
    
    [[WebClient sharedInstance] registerPushToken:self.pushToken callback:^(BOOL success) {
        _pushTokenRegistered = success;
        NSLog(@"Push token register success: %d", success);
    }];
}

-(void)deregisterPushFromServer
{
    
    DDLogDebug(@"DATA2: %@", self.data);

    DDLogInfo(@"Push token: %@", self.data[@"user.pushToken"]);
    
    [[WebClient sharedInstance] deregisterPushToken:self.data[@"user.pushToken"] callback:^(BOOL success) {
       
        if(!success)
        {
            DDLogInfo(@"Unable to deregister device from push notifications.");
        }
        
    }];
}



@end
