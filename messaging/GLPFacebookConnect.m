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
#import "NSError+FBError.h"
#import "FBWebDialogs.h"
#import "WebClientHelper.h"
#import "NSNotificationCenter+Utils.h"
#import "FBFrictionlessRecipientCache.h"

@interface GLPFacebookConnect () {
    void (^_openCompletionHandler)(BOOL, NSString *, NSString *);
    NSString *_universityEmail;
    NSInteger _facebookId;
    NSInteger _groupRemoteKey;
}

/** Instance used for cached user's friends. */
@property (strong, nonatomic) FBFrictionlessRecipientCache *friendCache;

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

-(id)init
{
    self = [super init];
    
    if(self)
    {
        _friendCache = [[FBFrictionlessRecipientCache alloc] init];
        [_friendCache prefetchAndCacheForSession:nil];
    }
    
    return self;
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
                                error:error friendList:NO];
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

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error friendList:(BOOL)friends
{
    switch (state) {
            
        case FBSessionStateOpen: {
            
            NSLog(@"Facebook state open.");

            
            if(friends)
            {
                [self inviteFriends];
            }
            else
            {
                [self registerUsingFacebookToken];
            }
            
            break;
        }
        case FBSessionStateClosed: {
//            [FBSession.activeSession closeAndClearTokenInformation];
//            NSLog(@"Facebook login closed");
//            [[SessionManager sharedInstance] cleanSession];
//            break;
        }
        case FBSessionStateClosedLoginFailed: {
            
        
            NSLog(@"Facebook login failed. %@", error);
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


#pragma mark - Invite friends

-(void)inviteFriends
{
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:[NSString stringWithFormat:@"Invite friends to Gleepost"]
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error)
                                                      {
                                                          // Case A: Error launching the dialog or sending request.
                                                          DDLogInfo(@"Error sending request. %@", error.localizedDescription);
                                                      } else
                                                      {
                                                          if (result == FBWebDialogResultDialogNotCompleted)
                                                          {
                                                              // Case B: User clicked the "x" icon
                                                              DDLogInfo(@"User canceled request.");
                                                              [self showKeyboardToThePreviousView];

                                                          } else
                                                          {
                                                              DDLogInfo(@"Request has been sent.");

                                                              [self manageFacebookInvitationsResult:resultURL];
                                                              [self showKeyboardToThePreviousView];

                                                          }
                                                      }}
                                              friendCache:_friendCache];
    
}

-(void)manageFacebookInvitationsResult:(NSURL *)resultURL
{
    NSDictionary *resultDictionary = [self parseURLParams:[resultURL query]];
    
    if(![resultDictionary objectForKey:@"error_code"])
    {
        NSArray * fbIds = [self parseUsersFacebookIdsWithDictionary:[self parseURLParams:[resultURL query]]];
        
        
        [self informAPIAboutInvitationWithFBIds:fbIds];
    }
}

#pragma mark - Helpers

- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

-(void)showKeyboardToThePreviousView
{
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"SHOW_KEYBOARD" object:nil userInfo:nil];
}

-(NSArray *)parseUsersFacebookIdsWithDictionary:(NSDictionary *)resultDictionary
{
    NSMutableArray *usersIds = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *resultDict = resultDictionary.mutableCopy;
    
    [resultDict removeObjectForKey:@"request"];
    
    for(NSString *key in resultDict)
    {
        [usersIds addObject:[resultDict objectForKey:key]];
    }
    
    return usersIds;
}

#pragma mark - Client

-(void)informAPIAboutInvitationWithFBIds:(NSArray *)fbIds
{
    [[WebClient sharedInstance] inviteUsersViaFacebookWithGroupRemoteKey:_groupRemoteKey andUsersFacebookIds:fbIds withCallbackBlock:^(BOOL success) {
       
        //TODO: Create a pop up message to show to user the friends that he invited.
        
        if(success)
        {
            DDLogInfo(@"User had invited friends final success.");
            [WebClientHelper showInvitedFriendsToGroupViaFBWithNumberOfFriends:fbIds.count];
            
        }
        else
        {
            DDLogInfo(@"Problem to invite friends.");
            [WebClientHelper showStandardErrorWithTitle:@"Oops!" andContent:@"There was a problem inviting your selected facebook friends"];
        }
        
    }];
}

-(void)fetchFriendsWithSession:(FBSession *)session
{
    __block NSString *requestID = nil;
    __block NSString *userID = nil;
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:session message:@"Hello" title:@"sdsad" parameters:nil handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
       

        
        if (error) {
            // Error launching the dialog or sending the request.
            NSLog(@"Error sending request.");
        } else {
            if (result == FBWebDialogResultDialogNotCompleted) {
                // User clicked the "x" icon
                NSLog(@"User canceled request.");
            } else {
                // Handle the send request callback
                
                DDLogDebug(@"Result: %u, Error: %@, URL: %@", result, error, resultURL);

                NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                if (![urlParams valueForKey:@"request"])
                {
                    // User clicked the Cancel button
                    NSLog(@"User canceled request.");
                } else
                {
                    // User clicked the Send button
                    
                    requestID = [urlParams valueForKey:@"request"];
                    userID = [urlParams valueForKey:@"to%5B0%5D"];
                    
                    NSLog(@"Request ID: %@ : %@", requestID, userID);
                    
                }
            }
        }
        
    }];
    
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     
                                     // Optional parameter for sending request directly to user
                                     // with UID. If not specified, the MFS will be invoked
                                     userID, @"to",
                                     
                                     // Give the structured request information
                                     @"send", @"action_type",
                                     requestID, @"object_id",
                                     //                                                 @"230797090361137", @"app_id",
                                     nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Take this bomb to blast your way to victory!"
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      
                                                      DDLogDebug(@"Result after request: %u : %@ : %@", result, resultURL, error);
                                                      
                                                  }
     ];
}

-(void)fetchFriends
{

    
    [FBRequestConnection startForMeWithCompletionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error)
     {
         NSDictionary * userDetails = result;
         
         _facebookId = [userDetails[@"id"] integerValue];
         
         NSLog(@"facebook result: %ld error: %@", (long)_facebookId, error);
         
         
         
         /* make the API call */
         [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%ld/friends", (long)_facebookId]
                                      parameters:nil
                                      HTTPMethod:@"GET"
                               completionHandler:^(
                                                   FBRequestConnection *connection,
                                                   id result,
                                                   NSError *error
                                                   ) {
                                   
                                   if(error)
                                   {
                                       DDLogDebug(@"Error fb invite: %@", error);
                                   }
                                   else
                                   {
                                       DDLogDebug(@"RESULT fb invite: %@", result);
                                   }
                                   
                                   /* handle the result */
                               }];

         
     }];
}

-(void)inviteFriendsViaFBToGroupWithRemoteKey:(int)groupRemoteKey
{
    
    _groupRemoteKey = groupRemoteKey;
    
    NSArray *permissions = @[@"read_friendlists"];
    
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
                                          
                                      } else
                                      {
                                          [self sessionStateChanged:session
                                                              state:status
                                                              error:error
                                                         friendList:YES];
                                      }
                                  }];
    
    
    
    
    
    //    /* make the API call */
    //    [FBRequestConnection startWithGraphPath:@"/{friendlist-id}"
    //                                 parameters:nil
    //                                 HTTPMethod:@"GET"
    //                          completionHandler:^(
    //                                              FBRequestConnection *connection,
    //                                              id result,
    //                                              NSError *error
    //                                              ) {
    //
    //                              if(error)
    //                              {
    //                                  DDLogDebug(@"Error fb invite: %@", error);
    //                              }
    //                              else
    //                              {
    //                                  DDLogDebug(@"RESULT fb invite: %@", result);
    //                              }
    //
    //                              /* handle the result */
    //                          }];
    
}

@end
