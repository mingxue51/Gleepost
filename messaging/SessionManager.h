//
//  SessionManager.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPUser.h"

@interface SessionManager : NSObject

@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) NSInteger key;
@property (strong, nonatomic) GLPUser *user;

+ (SessionManager *)sharedInstance;

- (void)registerUserWithRemoteKey:(NSInteger)remoteKey andToken:(NSString *)token;

@end
