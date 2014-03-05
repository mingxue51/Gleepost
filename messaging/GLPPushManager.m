//
//  GLPPushManager.m
//  Gleepost
//
//  Created by Lukas on 11/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPPushManager.h"
#import "WebClient.h"
#import "SessionManager.h"

@interface GLPPushManager()

@property (strong, nonatomic) NSString *pushToken;
@property (assign, nonatomic) BOOL isPushTokenRegistered;

@end

@implementation GLPPushManager

static GLPPushManager *instance = nil;

+ (GLPPushManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPPushManager alloc] init];
    });
    
    return instance;
}

- (void)savePushToken:(NSData *)token
{
    if(!ON_DEVICE) {
        return;
    }
    
    // convert from base64 to string
    const unsigned *tokenBytes = [token bytes];
    _pushToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                      ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                      ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                      ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    // register to the server if user is logged in, otherwise wait for the login
    if([[SessionManager sharedInstance] isLogged]) {
        [self registerPushTokenWithAuthParams:[SessionManager sharedInstance].authParameters];
    }
}

- (void)registerPushTokenWithAuthParams:(NSDictionary *)authParams
{
    if(!ON_DEVICE) {
        return;
    }
    
    DDLogInfo(@"Register push token: %@", _pushToken);
    
    if(_isPushTokenRegistered) {
        DDLogWarn(@"Push token already registered, abort");
        return;
    }
    
    if(!_pushToken) {
        DDLogError(@"Push token to register does not exist, abort");
        return;
    }
    
    // mark yes before starting the request in order to avoid to be called again during the request
    _isPushTokenRegistered = YES;
    
    [[WebClient sharedInstance] registerPushToken:_pushToken authParams:authParams callback:^(BOOL success) {
        _isPushTokenRegistered = success;
        NSLog(@"Push token register with success: %d", success);
    }];
}

- (void)unregisterPushTokenWithAuthParams:(NSDictionary *)authParams
{
    if(!ON_DEVICE) {
        return;
    }
    
    DDLogInfo(@"Unregister push token: %@", _pushToken);
    
    if(!_isPushTokenRegistered) {
        DDLogError(@"Push token already not registered, abort");
        return;
    }
    
    if(!_pushToken) {
        DDLogError(@"Push token to register does not exist, abort");
        return;
    }
    
    // mark no before starting the request in order to avoid to be called again during the request
    _isPushTokenRegistered = NO;
    
    [[WebClient sharedInstance] unregisterPushToken:_pushToken authParams:authParams callback:^(BOOL success) {
        _isPushTokenRegistered = !success;
        NSLog(@"Push token unregister with success: %d", success);
    }];
}



@end
