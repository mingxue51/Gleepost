//
//  LoginManager.m
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLoginManager.h"
#import "WebClient.h"
#import "GLPBackgroundRequestsManager.h"
#import "SessionManager.h"
#import "GLPContactDao.h"
#import "GLPUserDao.h"
#import "GLPContact.h"
#import "DatabaseManager.h"
#import "GLPThemeManager.h"
#import "ContactsManager.h"
#import "GLPNetworkManager.h"
#import "GLPLiveConversationsManager.h"
#import "GLPProfileLoader.h"
#import "UICKeyChainStore.h"

@implementation GLPLoginManager

+ (void)loginWithIdentifier:(NSString *)identifier andPassword:(NSString *)password shouldRemember:(BOOL)shouldRemember callback:(void (^)(BOOL success, NSString *errorMessage))callback
{
    [[WebClient sharedInstance] loginWithName:identifier password:password andCallbackBlock:^(BOOL success, GLPUser *user, NSString *token, NSDate *expirationDate, NSString *errorMessage) {
        
        if(!success) {
            callback(NO, errorMessage);
            return;
        }

        NSAssert(user.remoteKey != 0, @"User remote key can't be null");
        NSAssert(token, @"User token can't be null");
        NSAssert(expirationDate, @"User expiration date can't be null");
        
        NSDictionary *authParams = @{@"id": [NSNumber numberWithInt:user.remoteKey], @"token": token};
        
        // fetch additional info
        // user details
        [[WebClient sharedInstance] getUserWithKey:user.remoteKey authParams:authParams callbackBlock:^(BOOL success, GLPUser *userWithDetials) {
            
            if(!success) {
                callback(NO, errorMessage);
                return;
            }
            
            // load contacts
            [[WebClient sharedInstance ] getContactsForUser:userWithDetials authParams:authParams callback:^(BOOL success, NSArray *contacts) {
             
                if(!success) {
                    callback(NO, errorMessage);
                    return;
                }
                
                userWithDetials.email = identifier;
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:shouldRemember] forKey:@"login.shouldremember"];
                
                if(shouldRemember) {
                    [UICKeyChainStore setString:identifier forKey:@"user.email"];
                    [UICKeyChainStore setString:password forKey:@"user.password"];
                } else {
                    [UICKeyChainStore removeAllItems];
                }
                
                [self validateLoginForUser:userWithDetials withToken:token expirationDate:expirationDate contacts:contacts];
                
                callback(YES, errorMessage);
            }];
        }];
    }];
}

+ (void)validateLoginForUser:(GLPUser *)user withToken:(NSString *)token expirationDate:(NSDate *)expirationDate contacts:(NSArray *)contacts
{
    [[DatabaseManager sharedInstance] initDatabase];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPUserDao save:user inDb:db];
        
        for(GLPContact *contact in contacts) {
            [GLPContactDao save:contact inDb:db];
        }
    }];
    
    [[SessionManager sharedInstance] registerUser:user withToken:token andExpirationDate:expirationDate];
    
    [GLPLoginManager performAfterLoginForUser:user];
}

+ (BOOL)performAutoLogin
{
    if(![DatabaseManager sharedInstance].exists) {
        return NO;
    }
    
    NSUInteger userRemoteKey = [[SessionManager sharedInstance] validUserRemoteKey];
    if(userRemoteKey == NSNotFound) {
        return NO;
    }
    
    [[DatabaseManager sharedInstance] initDatabase];
    
    __block GLPUser *user;
    [DatabaseManager run:^(FMDatabase *db) {
        user = [GLPUserDao findByRemoteKey:userRemoteKey db:db];
    }];
    
    if(!user) {
        DDLogError(@"User exists in session with remoteKey %d, but not in the database", userRemoteKey);
        return NO;
    }
    
    [[SessionManager sharedInstance] restoreUser:user];
    
    [GLPLoginManager performAfterLoginForUser:user];
    
    return YES;
}

+ (void)performAfterLoginForUser:(GLPUser *)user
{
    DDLogInfo(@"Logged in user remote key: %d", user.remoteKey);
    
    [[GLPNetworkManager sharedInstance] startNetworkOperations];
    [[GLPThemeManager sharedInstance] setNetwork:user.networkName];
    
    [[WebClient sharedInstance] markNotificationsRead:nil];
    [[WebClient sharedInstance] markConversationsRead:nil];
}

+ (void)logout
{
    [[SessionManager sharedInstance] deregisterPushFromServerWithCallBackBlock:^(BOOL success) {
        
        if(success)
        {
            [[GLPNetworkManager sharedInstance] stopNetworkOperations];
            [[[WebClient sharedInstance] operationQueue] cancelAllOperations];
            
            [[GLPLiveConversationsManager sharedInstance] clear];
            [[SessionManager sharedInstance] cleanSession];
            [[DatabaseManager sharedInstance] dropDatabase];
            
            [[GLPProfileLoader sharedInstance] initialiseLoader];
        }
    }];
    

    
}

@end