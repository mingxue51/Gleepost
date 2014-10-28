
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
#import "FBWebDialogs.h"
#import "WebClientHelper.h"
#import "NSNotificationCenter+Utils.h"
#import "FBFrictionlessRecipientCache.h"

@interface GLPFacebookConnect () {
    void (^_openCompletionHandler)(BOOL, NSString *, NSString *);
    void (^_inviteFriendsCompletionHandler) (BOOL, NSArray*);
    NSString *_universityEmail;
    NSInteger _facebookId;
    GLPGroup *_group;
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
    
    DDLogDebug(@"Email before connect: %@", email);
    
//    NSArray *permissions = @[@"basic_info"];
    
    NSArray *permissions = @[@"public_profile", @"user_friends"];
    
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
                //[self inviteFriends];
                

                
                
//                [self getFriends];
                [self getFriendsWithSession:session];
                [self associateCurrentAccountWithFacebook];
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

-(void)associateAlreadyRegisteredAccountWithFacebookTokenWithPassword:(NSString *)password andEmail:(NSString *)email withCallbackBlock:(void (^) (BOOL success))callback
{
    
    [[WebClient sharedInstance] associateWithFacebookAccountUsingFBToken:[self facebookLoginToken] withEMail:email withPassword:password andCallbackBlock:^(BOOL success) {
        
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
    if(post.eventTitle)
    {
        [self shareEventWithPost:post];
    }
    else
    {
        [self shareRegularPostWithPost:post];
    }
    
}

- (void)shareEventWithPost:(GLPPost *)eventPost
{
    DDLogInfo(@"Share event post to facebook %@", eventPost);
    
    id<FBOpenGraphAction> action = [self generateShareActionWithEventPost:eventPost];
    
    // Check if the Facebook app is installed and we can present the share dialog
    //    FBOpenGraphActionShareDialogParams *params = [self generateParametersWithAction:action];
    FBOpenGraphActionParams *params = [self generateParametersWithAction:action];
    
    
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params])
    {
        // Show the share dialog
        [self presentDialogWithOpenGraphAction:action withActionType:@"gleepost:share" andObjectName:@"event"];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else
    {
        // FALLBACK GOES HERE
        [WebClientHelper showNeedsFacebookAppError];
    }
}

- (void)shareRegularPostWithPost:(GLPPost *)regularPost
{
    DDLogInfo(@"Share regular post to facebook %@", regularPost);
    
    id<FBOpenGraphAction> action = [self generateShareActionWithRegularPost:regularPost];
    
    // Check if the Facebook app is installed and we can present the share dialog
    //    FBOpenGraphActionShareDialogParams *params = [self generateParametersWithAction:action];
    FBOpenGraphActionParams *params = [self generateParametersWithAction:action];
    
    
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params])
    {
        // Show the share dialog
        [self presentDialogWithOpenGraphAction:action withActionType:@"gleepost:share" andObjectName:@"post"];
        
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

-(id<FBOpenGraphAction>)generateShareActionWithEventPost:(GLPPost *)post
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

- (id<FBOpenGraphAction>)generateShareActionWithRegularPost:(GLPPost *)post
{
    NSMutableDictionary<FBGraphObject> *object =
    (NSMutableDictionary<FBGraphObject> *)[FBGraphObject openGraphObjectForPostWithType:@"gleepost:post"
                                                                                  title:post.content
                                                                                  image:post.imagesUrls[0]
                                                                                    url:[NSString stringWithFormat:@"%@posts/%ld", @"https://m.facebook.com/apps/gleepost/", (long)post.remoteKey]
                                                                            description:nil];
    
    
    // Create an action
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    
    // Link the object to the action
    [action setObject:object forKey:@"post"];
    
    return action;
}

-(FBOpenGraphActionParams *)generateParametersWithAction:(id<FBOpenGraphAction>)action
{
//    FBOpenGraphActionShareDialogParams *params = [[FBOpenGraphActionShareDialogParams alloc] init];
    FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];

    params.action = action;
    params.actionType = @"gleepost:share";
    
    return params;
}

#pragma mark - Invite friends

-(void)inviteFriendsViaFBToGroupWithRemoteKey:(GLPGroup* )group completionHandler:(void (^)(BOOL success, NSArray *fbFriends))completionHandler
{
    
    _group = group;
    _inviteFriendsCompletionHandler = completionHandler;
    
//    NSArray *permissions = @[@"read_friendlists"];
    //user_friends
    NSArray *permissions = @[@"user_friends"];

    
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

- (NSArray *)parseInvitedUsersFacebookKeysFromURLResult:(NSDictionary *)urlResult
{
    NSMutableArray *invitedUserKeys = [[NSMutableArray alloc] init];
    
    for(NSString *key in urlResult)
    {
        if(![key isEqualToString:@"request"])
        {
            [invitedUserKeys addObject:urlResult[key]];
        }
    }
    
    return invitedUserKeys;
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

- (NSString *)parseUsersImageWithFriendPictureObject:(NSDictionary *)pictureObject
{
    NSDictionary *pictureDictionary =  pictureObject[@"data"];
    
    return pictureDictionary[@"url"];
}

//- (GLPUser *)parseFacebookFriendWithObject:(NSDictionary *)facebookObject
//{
//    
//}

#pragma mark - Client

-(void)informAPIAboutInvitationWithFBIds:(NSArray *)fbIds
{
    [[WebClient sharedInstance] inviteUsersViaFacebookWithGroupRemoteKey:_group.remoteKey andUsersFacebookIds:fbIds withCallbackBlock:^(BOOL success) {
        
        if(success)
        {
            DDLogInfo(@"Association with api success.");
//            [WebClientHelper showInvitedFriendsToGroupViaFBWithNumberOfFriends:fbIds.count];
            
        }
        else
        {
            DDLogInfo(@"Problem to associate with api.");
            [WebClientHelper showStandardErrorWithTitle:@"Oops!" andContent:@"There was a problem inviting your selected facebook friends"];
        }
        
    }];
}

-(void)associateCurrentAccountWithFacebook
{
    [[WebClient sharedInstance] associateWithFacebookAccountUsingFBToken:[self facebookLoginToken] withCallbackBlock:^(BOOL success) {
       
        
        if(success)
        {
            DDLogDebug(@"Associated with facebook account");
        }
        else
        {
            DDLogDebug(@"Not able to associated with facebook account");
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

- (void)getFriendsWithSession:(FBSession *)session
{
    FBAccessTokenData *accessTok = session.accessTokenData;
    
    DDLogInfo(@"Access token facebook  %@", accessTok.accessToken);
    
    NSDictionary *params = @{ @"fields": @"id,name,first_name,last_name,picture" };
    
    __block NSInteger usersFacebookID = -1;
    
    [[WebClient sharedInstance] requestUsersFacebookIDWithToken:accessTok.accessToken withCallback:^(BOOL success, NSInteger usersID) {
       
        if(success)
        {
            usersFacebookID = usersID;
            
            DDLogDebug(@"Users ID %ld", (long)usersFacebookID);
            
            NSMutableArray *fbFriends = [[NSMutableArray alloc] init];
            
            NSString *path = [NSString stringWithFormat:@"/%ld/taggable_friends", (long)usersFacebookID];
            
            //@"/726435481/taggable_friends"
            
            //[self fetchFriends];
            [FBRequestConnection startWithGraphPath:path
                                         parameters:params
                                         HTTPMethod:@"GET"
                                  completionHandler:^(
                                                      FBRequestConnection *connection,
                                                      id result,
                                                      NSError *error
                                                      ) {
                                      
                                      if(error)
                                      {
                                          _inviteFriendsCompletionHandler(NO, nil);
                                          return;
                                      }
                                      
                                      
                                      
                                      NSArray* friends = [result objectForKey:@"data"];
                                      
                                      
                                      for (NSDictionary<FBGraphUser>* friend in friends)
                                      {
                                          
                                          NSString *friendID = friend[@"id"];
                                          
                                          DDLogDebug(@"Friend key %@", friendID);
                                          
                                          
                                          GLPUser *user = [[GLPUser alloc] initWithName:friend.name withId:[friend.objectID integerValue] andImageUrl:[self parseUsersImageWithFriendPictureObject:friend[@"picture"]]];
                                          
                                          user.facebookTemporaryToken = friendID;
                                          
                                          [fbFriends addObject:user];
                                      }
                                      
                                      _inviteFriendsCompletionHandler(YES, fbFriends);
                                  }];
        }
        else
        {
            
        }
        
        
    }];
    

}

-(void)getFriends
{
    NSMutableArray *fbFriends = [[NSMutableArray alloc] init];
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        
        
        if(error)
        {
            _inviteFriendsCompletionHandler(NO, nil);
            return;
        }
        
        NSArray* friends = [result objectForKey:@"data"];
        
        for (NSDictionary<FBGraphUser>* friend in friends)
        {
            GLPUser *user = [[GLPUser alloc] initWithName:friend.name withId:[friend.objectID integerValue] andImageUrl:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal", friend.objectID]];
            
            [fbFriends addObject:user];
        }
        
        _inviteFriendsCompletionHandler(YES, fbFriends);
        
    }];
}

-(void)sendRequestToFriendWithFriendsIds:(NSArray *)friendIDs withCompletionCallback:(void (^) (NSString *status))completionCallback
{
    // Normally this won't be hardcoded but will be context specific, i.e. players you are in a match with, or players who recently played the game etc
//    NSArray *friendIDs = [[NSArray alloc] initWithObjects:
//                                 @"1474356782", nil];
    
//    SBJsonWriter *jsonWriter = [SBJsonWriter new];
//    NSDictionary *challenge =  [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d", nScore], @"challenge_score", nil];
//    NSString *challengeStr = [jsonWriter stringWithObject:challenge];
    
    NSString *challengeStr = @"Invitation test.";

    DDLogDebug(@"Friends ids %@", friendIDs);
    
//    friendIDs = [[NSArray alloc] initWithObjects:@"726435481", nil];
    
    
    //Facebook doen't let us to do that.
//    for(NSString *userToken in friendIDs)
//    {
//        [[WebClient sharedInstance] requestUsersFacebookIDWithToken:userToken withCallback:^(BOOL success, NSInteger usersID) {
//           
//            if(success)
//            {
//                DDLogDebug(@"-> %ld", (long)usersID);
//            }
//            
//        }];
//    }
    
    
    
    
    // Create a dictionary of key/value pairs which are the parameters of the dialog
    
    // 1. No additional parameters provided - enables generic Multi-friend selector
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     // 2. Optionally provide a 'to' param to direct the request at a specific user
                                     [friendIDs componentsJoinedByString:@","], @"to", // Ali
                                     // 3. Suggest friends the user may want to request, could be game context specific?
                                     //[suggestedFriends componentsJoinedByString:@","], @"suggestions",
                                     challengeStr, @"data",
                                     nil];
    
    
    
    if (_friendCache == NULL) {
        _friendCache = [[FBFrictionlessRecipientCache alloc] init];
    }
    
    [_friendCache prefetchAndCacheForSession:nil];
    
    FBSession *session =  FBSession.activeSession;
    
    DDLogDebug(@"Session %@", session);
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:session
                                                  message:[NSString stringWithFormat:@"You're invited to join %@ on Gleepost.", _group.name]
                                                    title:@"Group invitation at Gleepost."
                                               parameters:params
                                                  handler:^(FBWebDialogResult result,
                                                            NSURL *resultURL,
                                                            NSError *error) {
                                                      
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          DDLogInfo(@"Error sending request.");
                                                          completionCallback(@"error");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              DDLogInfo(@"User canceled request.");
                                                              completionCallback(@"canceled");
                                                          } else {
                                                              
                                                            
                                                              NSDictionary *finalResult = [self parseURLParams:[resultURL query]];
                                                              
                                                              if([finalResult objectForKey:@"error_code"])
                                                              {
                                                                  DDLogInfo(@"User canceled request.");
                                                                  completionCallback(@"canceled");
                                                              }
                                                              else
                                                              {
                                                                  DDLogInfo(@"Request Sent.");
                                                                  [self informAPIAboutInvitationWithFBIds:friendIDs];
                                                                  completionCallback(@"sent");
                                                              }
                                                          }
                                                      }
                                                  }
                                              friendCache:_friendCache];
}

- (void)showDefaultFacebookInvitationScreenWithCompletionCallback:(void (^) (NSString *status))completionCallback
{
    NSString *challengeStr = @"Invitation test.";
    
    
    // Create a dictionary of key/value pairs which are the parameters of the dialog
    
    // 1. No additional parameters provided - enables generic Multi-friend selector
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     // 2. Optionally provide a 'to' param to direct the request at a specific user
                                     // Ali
                                     // 3. Suggest friends the user may want to request, could be game context specific?
                                     //[suggestedFriends componentsJoinedByString:@","], @"suggestions",
                                     challengeStr, @"data",
                                     nil];
    
    
    
    if (_friendCache == NULL) {
        _friendCache = [[FBFrictionlessRecipientCache alloc] init];
    }
    
    [_friendCache prefetchAndCacheForSession:nil];
    
    FBSession *session =  FBSession.activeSession;
    
    DDLogDebug(@"Session %@", session);
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:session
                                                  message:[NSString stringWithFormat:@"You're invited to join %@ on Gleepost.", _group.name]
                                                    title:@"Group invitation at Gleepost."
                                               parameters:params
                                                  handler:^(FBWebDialogResult result,
                                                            NSURL *resultURL,
                                                            NSError *error) {
                                                      
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          DDLogInfo(@"Error sending request.");
                                                          completionCallback(@"error");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              DDLogInfo(@"User canceled request.");
                                                              completionCallback(@"canceled");
                                                          } else {
                                                              
                                                              
                                                              
                                                              NSDictionary *finalResult = [self parseURLParams:[resultURL query]];
                                                              
                                                              DDLogDebug(@"Result URL %@", finalResult);

                                                              
                                                              if([finalResult objectForKey:@"error_code"])
                                                              {
                                                                  DDLogInfo(@"User canceled request.");
                                                                  completionCallback(@"canceled");
                                                              }
                                                              else
                                                              {
                                                                  NSArray *invitedUsersKeys = [self parseInvitedUsersFacebookKeysFromURLResult:finalResult];
                                                                  
                                                                  DDLogInfo(@"Request Sent %@", invitedUsersKeys);
                                                                  [self informAPIAboutInvitationWithFBIds:invitedUsersKeys];
                                                                  completionCallback(@"sent");
                                                              }
                                                          }
                                                      }
                                                  }
                                              friendCache:_friendCache];
}





@end
