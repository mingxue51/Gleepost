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
#import "WebClient.h"

@implementation GLPFacebookConnect

+ (void)connectWithFacebook {
    NSArray *permissions = @[@"email"];
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      if (error) {
                                          NSLog(@"FBSession connectWithFacebook failed");
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured while logging in through Facebook" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                          [alertView show];
                                      } else {
                                          NSLog(@"FBSession sessionStateChanged");
                                          [self sessionStateChanged:session state:status error:error];
                                      }
                                  }];
}

+ (BOOL)isFacebookSessionValid {
    return (FBSession.activeSession.state == FBSessionStateOpen);
}

+ (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            #warning TODO: check email id implementation
            [[WebClient sharedInstance] registerViaFacebookToken:[GLPFacebookConnect facebookLoginToken]
                                                  withNilOrEmail:nil
                                                andCallbackBlock:^(BOOL success, NSString *responseObject, int userRemoteKey) {
                                                    NSLog(@"----- registered via FB");
                                                }];
            break;
        }
        case FBSessionStateClosed: {
            NSLog(@"Facebook login closed");
            [[SessionManager sharedInstance] cleanSession];
            break;
        }
        case FBSessionStateClosedLoginFailed: {
            NSLog(@"Facebook login failed.");
        }
        default:
            break;
    }
}

+ (NSString *)facebookLoginToken {
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [FBSessionTokenCachingStrategy defaultInstance];
    return [tokenCachingStrategy fetchTokenInformation][FBTokenInformationTokenKey];
}

@end
