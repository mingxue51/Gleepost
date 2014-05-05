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
#import "NSError+FBError.h"
#import "FBShareDialogParams.h"
#import "FBDialogs.h"

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
    _universityEmail = email;
    //TODO: Remove that after testing.
//    _universityEmail = @"admin@gleepost.com";

    
    DDLogDebug(@"Email before connect: %@", email);
    
    NSArray *permissions = @[@"basic_info"];
    [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        
        if (error)
        {
            NSString *errorMessage = nil;
            
            if([error fberrorShouldNotifyUser])
            {
                errorMessage = [error fberrorUserMessage];
            }
            
            NSLog(@"FBSession connectWithFacebook failed :%@", errorMessage);
            [FBSession.activeSession closeAndClearTokenInformation];
            
            completionHandler(NO, nil, errorMessage);
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
            [self registerUsingFacebookToken];
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

-(void)registerUsingFacebookToken
{
    [[WebClient sharedInstance] registerViaFacebookToken:[self facebookLoginToken] withEmailOrNil:_universityEmail andCallbackBlock:^(BOOL success, NSString *responseObject) {
        
        if (success)
        {
            NSLog(@"Facebook registration succesful: %@", responseObject);
            
            // get User's name from Facebook
            [FBRequestConnection
            startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                               id<FBGraphUser> user,
                                               NSError *error) {
                
                 if(!error)
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
}

- (NSString *)facebookLoginToken {
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [FBSessionTokenCachingStrategy defaultInstance];
    NSLog(@"FB Token: %@", [tokenCachingStrategy fetchTokenInformation][FBTokenInformationTokenKey]);
    return [tokenCachingStrategy fetchTokenInformation][FBTokenInformationTokenKey];
}


#pragma mark - Share post

-(void)sharePostWithPost:(GLPPost *)post
{
//    NSArray *permissions = @[@"publish_actions"];
//    
//    [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
    
        
//        DDLogDebug(@"Sesssion: %@, Error: %@", session, error);
        
        // NOTE: pre-filling fields associated with Facebook posts,
        // unless the user manually generated the content earlier in the workflow of your app,
        // can be against the Platform policies: https://developers.facebook.com/policy
        
        // Put together the dialog parameters
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       @"Sharing Tutorial", @"name",
//                                       @"Build great social apps and get more installs.", @"caption",
//                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
//                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
//                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
//                                       nil];
//        
//        // Make the request
//        [FBRequestConnection startWithGraphPath:@"/me/feed"
//                                     parameters:params
//                                     HTTPMethod:@"POST"
//                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                  if (!error)
//                                  {
//                                      // Link posted successfully to Facebook
//                                      DDLogDebug(@"%@",[NSString stringWithFormat:@"result: %@", result]);
//                                  } else
//                                  {
//                                      // An error occurred, we need to handle the error
//                                      // See: https://developers.facebook.com/docs/ios/errors
//                                      DDLogDebug(@"%@",[NSString stringWithFormat:@"%@", error.description]);
//                                  }
//                              }];
//        
//    }];
    

    
    
    

    
    // Check if the Facebook app is installed and we can present the share dialog
//    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
//    params.link = [NSURL URLWithString:[NSString stringWithFormat:@"https://gleepost.com/posts/%d",post.remoteKey]];
//    params.name = post.eventTitle;
//    params.caption = @"Build great social apps and get more installs.";
//    params.picture = [NSURL URLWithString:post.imagesUrls[0]];
//    params.description = post.content;
//    
//    // If the Facebook app is installed and we can present the share dialog
//    if ([FBDialogs canPresentShareDialogWithParams:params])
//    {
//        // Present the share dialog
//        DDLogDebug(@"Present share dialog.");
//        
//        // Present share dialog
//        [FBDialogs presentShareDialogWithLink:params.link
//                                         name:params.name
//                                      caption:nil
//                                  description:params.description
//                                      picture:params.picture
//                                  clientState:nil
//                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                          if(error)
//                                          {
//                                              // An error occurred, we need to handle the error
//                                              // See: https://developers.facebook.com/docs/ios/errors
//                                              DDLogDebug(@"%@",[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
//                                              
//                                          } else
//                                          {
//                                              // Success
//                                              NSLog(@"result %@", results);
//                                          }
//                                      }];
//        
//    }
//    
//    else {
//        
//        
//    }
    
    
    DDLogDebug(@"Post to be shared: %@", post);
    
    NSMutableDictionary<FBGraphObject> *object =
    (NSMutableDictionary<FBGraphObject> *)[FBGraphObject openGraphObjectForPostWithType:@"gleepost:event"
                                            title:post.eventTitle
                                            image:post.imagesUrls[0]
                                              url:[NSString stringWithFormat:@"%@posts/%d", @"https://m.facebook.com/apps/gleepost/", post.remoteKey]
                                      description:post.content];
    
    
    // Create an action
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    
    // Link the object to the action
    [action setObject:object forKey:@"event"];
    
    
    
    
    // Check if the Facebook app is installed and we can present the share dialog
//    FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
//    params.action = action;
//    params.actionType = @"fbogsamplesd:eat";
//    
//    // If the Facebook app is installed and we can present the share dialog
//    if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
        // Show the share dialog
        [FBDialogs presentShareDialogWithOpenGraphAction:action
                                              actionType:@"gleepost:post"
                                     previewPropertyName:@"event"
                                                 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                     if(error) {
                                                         // There was an error
                                                         NSLog(@"Error share: %@",[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                     } else {
                                                         // Success
                                                         NSLog(@"result %@", results);
                                                     }
                                                 }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
//    } else {
//        // FALLBACK GOES HERE
//    }
    
    
    
     
//     [FBRequestConnection startForPostWithGraphPath:@"me/objects/gleepost:listing"
//                                        graphObject:object
//                                  completionHandler:^(FBRequestConnection *connection,
//                                                      id result,
//                                                      NSError *error) {
//                                      // handle the result
//                                      
//                                      if(error)
//                                      {
//                                          DDLogDebug(@"ERROR: %@", error);
//                                      }
//                                      else
//                                      {
//                                          DDLogDebug(@"RESULT: %@", result);
//                                      }
//                                  }];
}

@end
