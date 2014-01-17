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
//#import "GLPPostOperationManager.m"
#import "GLPFacebookConnect.h"
#import "RemoteParser.h"

@implementation GLPLoginManager

+ (void)loginWithIdentifier:(NSString *)identifier andPassword:(NSString *)password callback:(void (^)(BOOL success))callback
{
    [[WebClient sharedInstance] loginWithName:identifier password:password andCallbackBlock:^(BOOL success, GLPUser *user, NSString *token, NSDate *expirationDate) {
        
        if(!success) {
            callback(NO);
            return;
        }

        NSAssert(user.remoteKey != 0, @"User remote key can't be null");
        NSAssert(token, @"User token can't be null");
        NSAssert(expirationDate, @"User expiration date can't be null");
        
        loadData(user, token, expirationDate, callback);
    }];
}

+ (void)loginFacebookUserWithName:(NSString *)name response:(NSString *)response callback:(void (^)(BOOL success))callback {
    NSDictionary *json = (NSDictionary *)response;
    
    GLPUser *user = [[GLPUser alloc] init];
    user.remoteKey = [json[@"id"] integerValue];
    user.name = name;
    
    NSString *token = json[@"value"];
    NSDate *expirationDate = [RemoteParser parseDateFromString:json[@"expiry"]];
    
    loadData(user, token, expirationDate, ^(BOOL success) {
        callback(success);
    });
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
    
//    [[SessionManager sharedInstance] registerUser:user withToken:token andExpirationDate:expirationDate];
    [[WebClient sharedInstance] startWebSocketIfLoggedIn];
    [[GLPThemeManager sharedInstance] setNetwork:user.networkName];
}

+ (void)loginFromExistingSessionUser
{
    //[[WebClient sharedInstance] initWebSocket];
}

+ (void)logout
{
    [[WebClient sharedInstance] stopWebSocket];
    [[[WebClient sharedInstance] operationQueue] cancelAllOperations];

    [[SessionManager sharedInstance] cleanSession];
    [[DatabaseManager sharedInstance] dropDatabase];
}

# pragma mark - Helper function for loading user data
void loadData(GLPUser *user, NSString *token, NSDate *expirationDate, void (^callback)(BOOL success)) {
    [[SessionManager sharedInstance] registerUser:user withToken:token andExpirationDate:expirationDate];
    

    NSDictionary *authParams = @{@"id": [NSNumber numberWithInt:user.remoteKey], @"token": token};
        
    // fetch additional info
    // user details
    [[WebClient sharedInstance] getUserWithKey:user.remoteKey authParams:authParams callbackBlock:^(BOOL success, GLPUser *userWithDetials) {
        
        if(!success) {
            callback(NO);
            return;
        }
        
        // load contacts
        [[WebClient sharedInstance ] getContactsForUser:userWithDetials authParams:authParams callback:^(BOOL success, NSArray *contacts) {
         
            if(!success) {
                callback(NO);
                return;
            }
            
            [GLPLoginManager validateLoginForUser:userWithDetials withToken:token expirationDate:expirationDate andContacts:contacts];
            
            callback(YES);
        }];
    }];
}

@end