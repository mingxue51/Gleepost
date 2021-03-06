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
#import <SDWebImage/UIImageView+WebCache.h>
#import "GLPPendingPostsManager.h"
#import "CategoryManager.h"
#import "GLPLiveGroupManager.h"
#import "GLPLiveGroupConversationsManager.h"
#import "ImageFormatterHelper.h"
#import "CampusLiveManager.h"

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
        [[WebClient sharedInstance] getUserWithKey:user.remoteKey authParams:authParams callbackBlock:^(BOOL success, GLPUser *userWithDetails) {
            
            if(!success) {
                callback(NO, errorMessage);
                return;
            }
            
            userWithDetails.email = identifier;
            
            [self rememberUser:shouldRemember withIdentifier:identifier andPassword:password];
            //                [self validateLoginForUser:userWithDetials withToken:token expirationDate:expirationDate contacts:contacts];
            [self validateLoginForUser:userWithDetails withToken:token expirationDate:expirationDate];
            
            
            callback(YES, errorMessage);

            
            // there is no need to load contacts on that version of the app.
//            [[WebClient sharedInstance ] getContactsForUser:userWithDetials authParams:authParams callback:^(BOOL success, NSArray *contacts) {
//             
//                if(!success) {
//                    callback(NO, errorMessage);
//                    return;
//                }
//                callback(YES, errorMessage);
//            }];
            

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

//TODO: This method is not used because we don't support contacts in our CORE app.
//This method is useful though because we can use it later in our SD app.
//+ (void)validateLoginForUser:(GLPUser *)user withToken:(NSString *)token expirationDate:(NSDate *)expirationDate andContacts:(NSArray *)contacts
//{
//    [[DatabaseManager sharedInstance] initDatabase];
//    
//    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//        [GLPUserDao save:user inDb:db];
//        
//        for(GLPContact *contact in contacts) {
//            [GLPContactDao save:contact inDb:db];
//        }
//    }];
//    
//    [[SessionManager sharedInstance] registerUser:user withToken:token andExpirationDate:expirationDate];
//    
//    [GLPLoginManager performAfterLoginForUser:user];
//}

+ (void)validateLoginForUser:(GLPUser *)user withToken:(NSString *)token expirationDate:(NSDate *)expirationDate
{
    [[DatabaseManager sharedInstance] initDatabase];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPUserDao save:user inDb:db];
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
    
//    __block GLPUser *user;
//    [DatabaseManager run:^(FMDatabase *db) {
//        DDLogDebug(@"DB error : findByRemoteKey");
//        user = [GLPUserDao findByRemoteKey:userRemoteKey db:db];
//    }];
    
    __block GLPUser *user;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        user = [GLPUserDao findByRemoteKey:userRemoteKey db:db];
    }];
    
    if(!user) {
        DDLogError(@"User exists in session with remoteKey %lu, but not in the database", (unsigned long)userRemoteKey);
        return NO;
    }
    
    [[SessionManager sharedInstance] restoreUser:user];
    
    [GLPLoginManager performAfterLoginForUser:user];
    
    return YES;
}

+ (void)performAfterLoginForUser:(GLPUser *)user
{
    DDLogInfo(@"Logged in user remote key: %ld", (long)user.remoteKey);
    
    [[GLPNetworkManager sharedInstance] startNetworkOperations];    
    [[WebClient sharedInstance] markNotificationsRead:nil];
    //That is removed because we are doing that by each message in conversation.
//    [[WebClient sharedInstance] markConversationsRead:nil];
}

#pragma mark - User image

+ (void)uploadImageAndSetUserImage:(UIImage *)userImage
{
    UIImage* imageToUpload = [ImageFormatterHelper imageWithImage:userImage scaledToHeight:320];
    
    NSData *imageData = UIImagePNGRepresentation(imageToUpload);
    
    NSLog(@"Image register image size: %d",imageData.length);
    
    [[WebClient sharedInstance] uploadImage:imageData ForUserRemoteKey:0 callbackBlock:^(BOOL success, NSString* response) {
        
        if(success)
        {
            NSLog(@"IMAGE UPLOADED. URL: %@",response);
            
            //Set image to user's profile.
            
            [GLPLoginManager setImageToUserProfile:response];
            
            //Save user's image to database and add to SessionManager.
            //TODO: REFACTOR / FACTORIZE THIS
            GLPUser *user = [SessionManager sharedInstance].user;
            user.profileImageUrl = response;
            [GLPUserDao updateUserWithRemotKey:user.remoteKey andProfileImage:response];
            
        }
    }];
}

+ (void)setImageToUserProfile:(NSString*)url
{
    DDLogDebug(@"GLPLoginManager : image started to associating with  %@",url);
    
    [[WebClient sharedInstance] uploadImageToProfileUser:url callbackBlock:^(BOOL success) {
        
        if(success)
        {
            NSLog(@"GLPLoginManager : profile image associated.");
        }
        else
        {
            NSLog(@"GLPLoginManager : profile image could not be ");
        }
    }];
}

+ (void)logout
{
    NSDictionary *authParams = [[SessionManager sharedInstance].authParameters copy];
    
    [[GLPNetworkManager sharedInstance] stopNetworkOperations];
    [[[WebClient sharedInstance] operationQueue] cancelAllOperations];
    
    [[CategoryManager sharedInstance] reset];
    [[GLPLiveConversationsManager sharedInstance] clear];
    [[SessionManager sharedInstance] cleanSession];
    [[DatabaseManager sharedInstance] dropDatabase];
    [GLPLoginManager disableAutoLogin];
    
    [[GLPProfileLoader sharedInstance] initialiseLoader];

    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];

    [[GLPPendingPostsManager sharedInstance] clean];
    
    [[GLPLiveGroupManager sharedInstance] clearData];
    [[GLPLiveGroupConversationsManager sharedInstance] clear];
    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_REMOVE_VC_NOTIFICATIONS object:self];
    
    [[GLPPushManager sharedInstance] unregisterPushTokenWithAuthParams:authParams];
    
    [[CampusLiveManager sharedInstance] clearData];
    
    [UICKeyChainStore removeItemForKey:@"facebook.email"];
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
    
    NSLog(@"GLPLoginManager : user remoteKey: %ld", (long)user.remoteKey);
    
    
    // fetch additional info
    // user details
    [[WebClient sharedInstance] getUserWithKey:user.remoteKey authParams:authParams callbackBlock:^(BOOL success, GLPUser *userWithDetails) {
        
        if(!success) {
            
            NSLog(@"GLPLoginManager : Failed to load user information.");
            callback(NO, @"Failed to load information.");
            return;
        }
        
        
        userWithDetails.email = userEmail;
        
        [GLPLoginManager validateLoginForUser:userWithDetails withToken:token expirationDate:expirationDate];
        
        callback(YES, @"Success.");
        
        // load contacts
//        [[WebClient sharedInstance ] getContactsForUser:userWithDetials authParams:authParams callback:^(BOOL success, NSArray *contacts) {
//         
//            if(!success) {
//                callback(NO, @"Failed to load contacts.");
//                return;
//            }
//            
//            userWithDetials.email = userEmail;
//            
//            [GLPLoginManager validateLoginForUser:userWithDetials withToken:token expirationDate:expirationDate andContacts:contacts];
//            
//            callback(YES, @"Success.");
//        }];
    }];
}

@end