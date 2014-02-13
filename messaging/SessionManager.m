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

@property (strong, nonatomic) NSString *dataPlistLoggedInPath;
@property (assign, nonatomic) BOOL currentUserFirstTime;
@property (strong, nonatomic) NSDictionary *usersData;

@end


@implementation SessionManager

@synthesize token = _token;
@synthesize user = _user;
@synthesize authParameters = _authParameters;
@synthesize pushToken=_pushToken;
@synthesize pushTokenRegistered=_pushTokenRegistered;
@synthesize currentCategory = _currentCategory;

NSString * const GLPSessionFileName = @"GLPSession.plist";

//Added to support first time tutorial.
NSString * const GLPLoggedInUsersFileName = @"/GLPLoggedInUser.plist";

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
    
    // init logged in plist path.
    NSString *rootPath2 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.dataPlistLoggedInPath = [rootPath2 stringByAppendingString:GLPLoggedInUsersFileName];
    
    _currentUserFirstTime = NO;
    
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
    
    
    //Check if it is user's first time.
    
    [self firstTimeLoggedIn];

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

-(void)firstTimeLoggedIn
{
    
    // load dictionnary data from saved file or create new one
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataPlistLoggedInPath] == YES)
    {
        
        //Load from plist file and add to the usersData.
        _usersData = [NSMutableDictionary dictionaryWithContentsOfFile:self.dataPlistLoggedInPath];
        
        DDLogError(@"Users DATA: %@", _usersData);
        
        for(NSString *key in _usersData)
        {
            if([key isEqualToString:_user.email])
            {
                DDLogDebug(@"USER EXIST!");
                _currentUserFirstTime = NO;
                
                return;
            }
        }
        
        //If the current user is not in the dictionary then is his first time. Otherwise it's not.
        _currentUserFirstTime = YES;
        
        [self saveLoggedInUsersData];

    }
    else
    {
        _currentUserFirstTime = YES;
        
        [self saveLoggedInUsersData];
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

-(void)saveLoggedInUsersData
{
    //Key email.
    //Value name.
    DDLogError(@"User name: %@ Email: %@", _user.name, _user.email);
    
//    NSDictionary *usersData = [NSDictionary dictionaryWithObjectsAndKeys:_user.name, _user.email, nil];
    
    NSMutableDictionary *usersData = [NSMutableDictionary dictionaryWithDictionary:_usersData];
    [usersData setObject:_user.name forKey:_user.email];
    
    
    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:usersData
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    
    if(plistData)
    {
        [plistData writeToFile:self.dataPlistLoggedInPath atomically:YES];
//        NSError *error;
//        [plistData writeToFile:self.dataPlistLoggedInPath options:NSDataWritingWithoutOverwriting error:&error];
        
    } else {
        [NSException raise:@"Save session data error" format:@"Error: %@", error];
    }
}

-(BOOL)isFirstTimeLoggedIn
{
    return _currentUserFirstTime;
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
    [[WebClient sharedInstance] deregisterPushToken:self.data[@"user.pushToken"] callback:^(BOOL success) {
       
        
        
    }];
}



@end
