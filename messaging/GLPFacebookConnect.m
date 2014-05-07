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
#import "WebClientHelper.h"

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

-(void)associateAlreadyRegisteredAccountWithFacebookTokenWithPassword:(NSString *)password withCallbackBlock:(void (^) (BOOL success))callback
{
    
    [[WebClient sharedInstance] associateWithFacebookAccountUsingFBToken:[self facebookLoginToken] withEMail:_universityEmail withPassword:password andCallbackBlock:^(BOOL success) {
        
        callback(success);
        
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
    id<FBOpenGraphAction> action = [self generateShareActionWithPost:post];
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBOpenGraphActionShareDialogParams *params = [self generateParametersWithAction:action];

    
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params])
    {
        // Show the share dialog
        [self presentDialogWithOpenGraphAction:action withActionType:@"gleepost:post" andObjectName:@"event"];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else
    {
        // FALLBACK GOES HERE
        [WebClientHelper showNeedsFacebookAppError];
    }
    
}

-(void)presentDialogWithOpenGraphAction:(id<FBOpenGraphAction>)action withActionType:(NSString *)actionType andObjectName:(NSString *)objectName
{
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:actionType
                                 previewPropertyName:objectName
                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                 
                                                 if(error)
                                                 {
                                                     DDLogInfo(@"%@",[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                 }
                                                 else
                                                 {
                                                     DDLogInfo(@"Share completed %@", results);
                                                 }
                                             }];
}

-(id<FBOpenGraphAction>)generateShareActionWithPost:(GLPPost *)post
{
    NSMutableDictionary<FBGraphObject> *object =
    (NSMutableDictionary<FBGraphObject> *)[FBGraphObject openGraphObjectForPostWithType:@"gleepost:event"
                                                                                  title:post.eventTitle
                                                                                  image:post.imagesUrls[0]
                                                                                    url:[NSString stringWithFormat:@"%@posts/%ld", @"https://m.facebook.com/apps/gleepost/", (long)post.remoteKey]
                                                                            description:post.content];
    
    
    // Create an action
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    
    // Link the object to the action
    [action setObject:object forKey:@"event"];
    
    return action;
}

-(FBOpenGraphActionShareDialogParams *)generateParametersWithAction:(id<FBOpenGraphAction>)action
{
    FBOpenGraphActionShareDialogParams *params = [[FBOpenGraphActionShareDialogParams alloc] init];
    params.action = action;
    params.actionType = @"gleepost:post";
    
    return params;
}

-(void)publishPostWithPost:(GLPPost *)post
{
    
}

@end
