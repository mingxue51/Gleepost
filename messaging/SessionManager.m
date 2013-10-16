//
//  SessionManager.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

@synthesize token, key;
@synthesize user = _user;

static SessionManager *instance = nil;

+ (SessionManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SessionManager alloc] init];
    });
    
    return instance;
}

- (void)registerUserWithRemoteKey:(NSInteger)remoteKey andToken:(NSString *)token
{
    GLPUser *user = [GLPUser MR_findFirstByAttribute:@"remoteKey" withValue:[NSNumber numberWithInteger:remoteKey]];
    
    if(!user) {
        user = [GLPUser MR_createEntity];
        user.remoteKeyValue = remoteKey;
    }
    
    self.user = user;
    self.token = token;
}

@end
