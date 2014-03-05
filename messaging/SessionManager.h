//
//  SessionManager.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPUser.h"
#import "GLPCategory.h"

@interface SessionManager : NSObject

@property (readonly, strong, nonatomic) NSString *token;
@property (readonly, strong, nonatomic) GLPUser *user;
@property (readonly, strong, nonatomic) NSDictionary *authParameters;
@property (strong, nonatomic) GLPCategory *currentCategory;

+ (SessionManager *)sharedInstance;

- (void)registerUser:(GLPUser *)user withToken:(NSString *)token andExpirationDate:(NSDate *)expirationDate;
- (BOOL)isSessionValid;
- (BOOL)isLogged;
- (BOOL)isUserSessionExists;
- (BOOL)isUserTokenValid;
- (NSUInteger)validUserRemoteKey;
- (void)restoreUser:(GLPUser *)user;
- (void)cleanSession;
-(BOOL)isFirstTimeLoggedIn;
-(void)firstTimeLoggedInActivate;

@end
