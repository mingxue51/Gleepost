//
//  GLPFacebookConnect.m
//  Gleepost
//
//  Created by Tanmay Khandelwal on 25/11/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPFacebookConnect.h"
#import "FBSession.h"
#import "SessionManager.h"
#import "FBSessionTokenCachingStrategy.h"
#import "FBRequestConnection.h"
#import "FBGraphUser.h"
#import "WebClient.h"

@interface GLPFacebookConnect () {
    void (^_openCompletionHandler)(BOOL, NSString *, NSString *);
    NSString *_universityEmail;
}

@end

@implementation GLPFacebookConnect

+ (GLPFacebookConnect *)sharedConnection {
    static dispatch_once_t once;
    static GLPFacebookConnect *sharedConnection;
    dispatch_once(&once, ^{
        sharedConnection = [[GLPFacebookConnect alloc] init];
    });
    
    return sharedConnection;
}

- (void)openSessionWithEmailOrNil:(NSString *)email completionHandler:(void (^)(BOOL success, NSString *name, NSString *response))completionHandler {
    _openCompletionHandler = completionHandler;
//    _universityEmail = email;
    _universityEmail = @"admin@gleepost.com";

    
    DDLogDebug(@"Email before connect: %@", email);
    
    NSArray *permissions = @[@"basic_info"];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      
                                      
                                      if (error)
                                      {
                                          NSLog(@"FBSession connectWithFacebook failed :%@", error);
                                          [FBSession.activeSession closeAndClearTokenInformation];
                                          
                                          completionHandler(NO, nil, nil);
                                      } else
                                      {
                                          [self sessionStateChanged:session
                                                              state:status
                                                              error:error];
                                      }
                                  }];
}

//- (BOOL)isFacebookSessionValid {
//    return (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded);
//}

- (void)handleDidBecomeActive {
    [FBSession.activeSession handleDidBecomeActive];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)logout {
    _universityEmail = nil;
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    
    
    switch (state) {
        case FBSessionStateOpen: {
            [[WebClient sharedInstance] registerViaFacebookToken:[self facebookLoginToken] withEmailOrNil:_universityEmail andCallbackBlock:^(BOOL success, NSString *responseObject) {

                if (success)
                {
                    NSLog(@"Facebook registration succesful: %@", responseObject);
                    
                    // get User's name from Facebook
                    [FBRequestConnection
                     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                       id<FBGraphUser> user,
                                                       NSError *error) {
                         if (!error)
                         {
                             _openCompletionHandler(YES, user.name, responseObject);
                             
                         } else
                         {
                             _openCompletionHandler(NO, nil, responseObject);
                         }
                     }];
                    
                } else
                {
                    NSLog(@"An error occurred while registering through facebook.");
                    _openCompletionHandler(NO, nil, responseObject);
                }
                
            }];
            break;
        }
        case FBSessionStateClosed: {
//            [FBSession.activeSession closeAndClearTokenInformation];
//            NSLog(@"Facebook login closed");
//            [[SessionManager sharedInstance] cleanSession];
//            break;
        }
        case FBSessionStateClosedLoginFailed: {
            NSLog(@"Facebook login failed.");
            break;
        }
        case FBSessionStateCreatedTokenLoaded: {
            NSLog(@"FBSessionStateCreatedTokenLoaded");
            break;
        }
        default:
            break;
    }
}

- (NSString *)facebookLoginToken {
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [FBSessionTokenCachingStrategy defaultInstance];
    NSLog(@"FB Token: %@", [tokenCachingStrategy fetchTokenInformation][FBTokenInformationTokenKey]);
    return [tokenCachingStrategy fetchTokenInformation][FBTokenInformationTokenKey];
}

@end
