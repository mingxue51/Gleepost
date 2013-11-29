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

+ (void)logout
{
    [[SessionManager sharedInstance] cleanSession];
    [[DatabaseManager sharedInstance] dropDatabase];
}

# pragma mark - Helper function for loading user data
void loadData(GLPUser *user, NSString *token, NSDate *expirationDate, void (^callback)(BOOL success)) {
    [[SessionManager sharedInstance] registerUser:user withToken:token andExpirationDate:expirationDate];
    
    // fetch additional info
    //TODO: not very nice to chain 3 requests
    [[WebClient sharedInstance] getUserWithKey:user.remoteKey callbackBlock:^(BOOL success, GLPUser *user) {
        
        if(!success) {
            callback(NO);
            return;
        }
        
        // load contacts
        //TODO: find better way
        [[WebClient sharedInstance ] getContactsWithCallbackBlock:^(BOOL success, NSArray *contacts) {
            if(!success) {
                callback(NO);
                return;
            }
            
            NSLog(@"LOGIN USER %@ - %d", user.name, user.remoteKey);
            
            [[DatabaseManager sharedInstance] initDatabase];
            
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                [GLPUserDao save:user inDb:db];
                
                for(GLPContact *contact in contacts) {
                    [GLPContactDao save:contact inDb:db];
                }
            }];
            
            // create session
//            [[SessionManager sharedInstance] registerUser:user withToken:token andExpirationDate:expirationDate];
            
            [[GLPBackgroundRequestsManager sharedInstance] startAll];
            
            callback(YES);
        }];
    }];
}

@end

