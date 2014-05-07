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
#import "GLPPushManager.h"
#import "GLPFacebookConnect.h"
#import "RemoteParser.h"

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
                
                [self rememberUser:shouldRemember withIdentifier:identifier andPassword:password];
//                [self validateLoginForUser:userWithDetials withToken:token expirationDate:expirationDate contacts:contacts];
                [self validateLoginForUser:userWithDetials withToken:token expirationDate:expirationDate andContacts:contacts];

                
                callback(YES, errorMessage);
            }];
        }];
    }];
}

/**
 Returns the e-mail only when the user is unverified.
 */

+ (void)loginFacebookUserWithName:(NSString *)name withEmail:(NSString *)email response:(NSString *)response callback:(void (^)(BOOL success, NSString *status, NSString *email))callback {
    
    NSDictionary *json = (NSDictionary *)response;
    
    DDLogDebug(@"FB RESPONSE: %@", json);
 
    
    NSString *responseFromServer = [RemoteParser parseFBStatusFromAPI:json];
    NSString *emailJson = json[@"email"];
    
    if([RemoteParser isAccountVerified:json])
    {
        
        if([RemoteParser isAccountRegistered:json])
        {
            //User registered.
            callback(NO, json[@"status"], nil);
        }
        else
        {
            GLPUser *user = [[GLPUser alloc] init];
            user.remoteKey = [json[@"id"] integerValue];
            user.name = name;
            user.email = email;
            //TODO: Take name surname here.
            NSString *token = json[@"value"];
            NSDate *expirationDate = [RemoteParser parseDateFromString:json[@"expiry"]];
            
            loadData(user, token, expirationDate, ^(BOOL success, NSString *response) {
                
                if(success)
                {
                    callback(YES, response, nil);
                }
                else
                {
                    callback(NO, response, nil);
                }
            });
        }
        

    }
    else
    {
        //Unverified.
        callback(NO, responseFromServer, emailJson);
    }
    

}

+ (void)validateLoginForUser:(GLPUser *)user withToken:(NSString *)token expirationDate:(NSDate *)expirationDate andContacts:(NSArray *)contacts
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
    NSDictionary *authParams = [[SessionManager sharedInstance].authParameters copy];
    
    [[GLPNetworkManager sharedInstance] stopNetworkOperations];
    [[[WebClient sharedInstance] operationQueue] cancelAllOperations];
    
    [[GLPLiveConversationsManager sharedInstance] clear];
    [[SessionManager sharedInstance] cleanSession];
    [[DatabaseManager sharedInstance] dropDatabase];
    [GLPLoginManager disableAutoLogin];
    
    [[GLPProfileLoader sharedInstance] initialiseLoader];
    
    [[GLPPushManager sharedInstance] unregisterPushTokenWithAuthParams:authParams];
}


# pragma mark - Remember user

+ (void)rememberUser:(BOOL)shouldRemember withIdentifier:(NSString *)identifier andPassword:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:shouldRemember] forKey:@"login.remember"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:shouldRemember] forKey:@"login.shouldautologin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(shouldRemember) {
        UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
        [store setString:identifier forKey:@"user.email"];
        [store setString:password forKey:@"user.password"];
        [store synchronize];
    } else {
        [UICKeyChainStore removeAllItems];
    }
}

+ (BOOL)isUserRemembered
{
    NSNumber *rememberMeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"login.remember"];
    return rememberMeNumber ? [rememberMeNumber boolValue] : NO;
}

+ (void)disableAutoLogin
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"login.shouldautologin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldAutoLogin
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"login.shouldautologin"];
    BOOL autologin = number ? [number boolValue] : NO;
    
    return autologin && [[SessionManager sharedInstance] isUserSessionValidForAutoLogin];
}

# pragma mark - Helper function for loading user data
void loadData(GLPUser *user, NSString *token, NSDate *expirationDate, void (^callback)(BOOL success, NSString *response)) {
//    [[SessionManager sharedInstance] registerUser:user withToken:token andExpirationDate:expirationDate];
    
    NSString *userEmail = user.email;
    
    NSDictionary *authParams = @{@"id": [NSNumber numberWithInt:user.remoteKey], @"token": token};
    
    NSLog(@"GLPLoginManager : user remoteKey: %d", user.remoteKey);
    
    
    // fetch additional info
    // user details
    [[WebClient sharedInstance] getUserWithKey:user.remoteKey authParams:authParams callbackBlock:^(BOOL success, GLPUser *userWithDetials) {
        
        if(!success) {
            
            NSLog(@"GLPLoginManager : Failed to load user information.");
            callback(NO, @"Failed to load information.");
            return;
        }
        
        // load contacts
        [[WebClient sharedInstance ] getContactsForUser:userWithDetials authParams:authParams callback:^(BOOL success, NSArray *contacts) {
         
            if(!success) {
                callback(NO, @"Failed to load contacts.");
                return;
            }
            
            userWithDetials.email = userEmail;
            
            [GLPLoginManager validateLoginForUser:userWithDetials withToken:token expirationDate:expirationDate andContacts:contacts];
            
            callback(YES, @"Success.");
        }];
    }];
}

@end