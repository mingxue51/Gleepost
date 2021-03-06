//
//  WebClient.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "WebClient.h"
#import "OHHTTPStubs.h"
#import "AFJSONRequestOperation.h"
#import "SessionManager.h"
#import "JsonParser.h"
#import "RemoteParser.h"
#import "AFJSONRequestOperation.h"
#import "GLPUserDao.h"
#import "AFNetworking.h"
#import "GLPMessageProcessor.h"
#import "NSUserDefaults+GLPAdditions.h"
#import "DateFormatterHelper.h"
#import "GLPVideo.h"
#import "GLPLocation.h"
#import "GLPVideoPostCWProgressManager.h"
#import "GLPLiveGroupPostManager.h"
#import "GLPLiveGroupManager.h"
#import "GLPPendingPostsManager.h"
#import "GLPLiveSummary.h"

@interface WebClient()

@property (strong, nonatomic) SessionManager *sessionManager;
@property (strong, nonatomic) SRWebSocket *webSocket;

@property (assign, nonatomic) BOOL networkStatusEvaluated; // controls if the network available status has been evaluated at least once

@end

@implementation WebClient

@synthesize isNetworkAvailable;
@synthesize webSocket=_webSocket;

static WebClient *instance = nil;

+ (WebClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DDLogDebug(@"WebClient init %@", [[SessionManager sharedInstance] serverPath]);
        instance = [[WebClient alloc] initWithBaseURL:[NSURL URLWithString:[[SessionManager sharedInstance] serverPath]]];
        instance.defaultSSLPinningMode = AFSSLPinningModeCertificate;
    });
    
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self) {
        return nil;
    }
    
    self.networkStatusEvaluated = NO;
    self.isNetworkAvailable = NO; // we init with NO and waiting for listener to update the value if the network is up
    
    [self setParameterEncoding:AFFormURLParameterEncoding];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    self.sessionManager = [SessionManager sharedInstance];
    
    __unsafe_unretained typeof(self) self_ = self;
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self_ updateNetworkAvailableStatus:status];
    }];
    
    if(ENV_FAKE_API) {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.absoluteString hasPrefix:kWebserviceBaseUrl];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            NSString *path = request.URL.absoluteString.lastPathComponent;
            NSRange range = [path rangeOfString:@"?"];
            if(range.location != NSNotFound) {
                path = [path substringWithRange:NSMakeRange(0, range.location)];
            }
            
            NSString *filePath = [NSString stringWithFormat:@"%@_%@.json", [request.HTTPMethod lowercaseString], path];
            NSLog(@"mock filepath %@", filePath);
            return [OHHTTPStubsResponse responseWithFile:filePath contentType:@"text/json" responseTime:0.5];
        }];
    }
    
    return self;
}

- (void)updateNetworkAvailableStatus:(AFNetworkReachabilityStatus) status
{
    BOOL available = (status == AFNetworkReachabilityStatusNotReachable) ? NO : YES;
    
    // update the status if it changed
    // or always update if it's the first time
    if(self.isNetworkAvailable != available || !self.networkStatusEvaluated) {
        self.networkStatusEvaluated = YES;
        self.isNetworkAvailable = available;
        
        // spread the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPNetworkStatusUpdate" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:self.isNetworkAvailable] forKey:@"status"]];
        
        NSLog(@"Network status changed, currently available: %d", self.isNetworkAvailable);
    }
}

- (void)activate
{
    [self updateNetworkAvailableStatus:self.networkReachabilityStatus];
}


- (void)loginWithName:(NSString *)name password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, GLPUser *user, NSString *token, NSDate *expirationDate, NSString *errorMessage))callbackBlock
{
    // ios6 temp fix
    if(!name || !password) {
        callbackBlock(NO, nil, nil, nil, nil);
        return;
    }
    
    [self postPath:@"login" parameters:@{@"email": name, @"pass": password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = (NSDictionary *) responseObject;
        
        GLPUser *user = [[GLPUser alloc] init];
        user.remoteKey = [json[@"id"] integerValue];
        user.name = name;

        NSString *token = json[@"value"];
        NSDate *expirationDate = [RemoteParser parseDateFromString:json[@"expiry"]];
        
        callbackBlock(YES, user, token, expirationDate, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogDebug(@"Operation: %@ With error: %@", operation, error);
        
        NSString *errorMessage = [RemoteParser parseLoginErrorMessage:error.localizedRecoverySuggestion];
        
        callbackBlock(NO, nil, nil, nil, errorMessage);
    }];
}

- (void)verifyUserWithToken:(NSString *)token callback:(void (^)(BOOL success))callbackBlock {
    NSString *postPath = [NSString stringWithFormat:@"verify/%@", token];
    
    [self postPath:postPath parameters:Nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}


/**
 TODO: DEPRECATED.
 */
- (void)registerWithName:(NSString *)name email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, NSString* responseObject, int userRemoteKey))callbackBlock
{
    __weak NSString *weakEmail = email;
    __weak NSString *weakName  = name;
    __weak NSString *weakPass  = password;
    
    [self postPath:@"register" parameters:@{@"user": name, @"pass": password, @"email": email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response during registration: %@", responseObject);
        int remotekey = [RemoteParser parseIdFromJson:responseObject];
        
        callbackBlock(YES, responseObject, remotekey);
        
        // saving user info for email verification
        [[NSUserDefaults standardUserDefaults] saveAuthParameterEmail:weakEmail];
        [[NSUserDefaults standardUserDefaults] saveAuthParameterName:weakName];
        [[NSUserDefaults standardUserDefaults] saveAuthParameterPass:weakPass];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
       NSLog(@"ERROR DURING REGISTRATION: %@", [RemoteParser parseRegisterErrorMessage:error.localizedRecoverySuggestion]);
        
        NSString *errorMessage = [RemoteParser parseRegisterErrorMessage:error.localizedRecoverySuggestion];
        
        callbackBlock(NO, errorMessage, -1);
    }];
}

#pragma mark - Facebook

- (void)registerViaFacebookToken:(NSString *)token
                  withEmailOrNil:(NSString *)email
                andCallbackBlock:(void (^)(BOOL success, NSString* responseObject))callbackBlock {
    
    if(!token)
    {
        callbackBlock(NO, @"There was a problem during facebook login. (token issue)");
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"token"] = token;
    if (email) parameters[@"email"] = email;
    
    DDLogDebug(@"register facebook: %@", parameters);
    
    [self postPath:@"fblogin" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response during FB login: %@", responseObject);
        callbackBlock(YES, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"ERROR DURING FACEBOOK REGISTRATION: %@", [RemoteParser parseFBRegisterErrorMessage:error.localizedRecoverySuggestion]);
        NSString *errorMessage = [RemoteParser parseFBRegisterErrorMessage:error.localizedRecoverySuggestion];
        callbackBlock(NO, errorMessage);
        
    }];
}

- (void)associateWithFacebookAccountUsingFBToken:(NSString *)fbToken withEMail:(NSString *)email withPassword:(NSString *)password
                                andCallbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:fbToken, @"fbtoken", email, @"email", password, @"pass",nil];
    
    [self postPath:@"profile/facebook" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogDebug(@"Explicit accosiation with facebook success: %@.", responseObject);

        
        callbackBlock(YES);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogDebug(@"Explicit accosiation with facebook failed: %@", error);

        
        callbackBlock(NO);
        
    }];
    
}

- (void)associateWithFacebookAccountUsingFBToken:(NSString *)fbToken withCallbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[SessionManager sharedInstance].authParameters];
    
    params[@"fbToken"] = fbToken;
    
    [self postPath:@"profile/facebook" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO);
        
    }];
    
}

- (void)requestUsersFacebookIDWithToken:(NSString *)usersToken withCallback:(void (^) (BOOL success, NSInteger usersID))callback
{
    NSString *path = [NSString stringWithFormat:@"https://graph.facebook.com/me?fields=id&access_token=%@", usersToken];
    
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSInteger facebookID = [responseObject[@"id"] integerValue];
        
        callback(YES, facebookID);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callback(NO, -1);
        
    }];
}

- (void)registerWithName:(NSString *)name surname:(NSString*)surname email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, NSString* responseObject, int userRemoteKey))callbackBlock
{
    __weak NSString *weakEmail = email;
    __weak NSString *weakName  = name;
    __weak NSString *weakSurname  = surname;
    __weak NSString *weakPass  = password;
    
    [self postPath:@"register" parameters:@{@"first": name, @"last": surname, @"pass": password, @"email": email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response during registration: %@", responseObject);
        int remotekey = [RemoteParser parseIdFromJson:responseObject];
        
        callbackBlock(YES, responseObject, remotekey);
        
        // saving user info for email verification
        [[NSUserDefaults standardUserDefaults] saveAuthParameterEmail:weakEmail];
        [[NSUserDefaults standardUserDefaults] saveAuthParameterName:weakName];
        [[NSUserDefaults standardUserDefaults] saveAuthParameterSurname:weakSurname];
        [[NSUserDefaults standardUserDefaults] saveAuthParameterPass:weakPass];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"ERROR DURING REGISTRATION: %@", [RemoteParser parseRegisterErrorMessage:error.localizedRecoverySuggestion]);
        
        NSString *errorMessage = [RemoteParser parseRegisterErrorMessage:error.localizedRecoverySuggestion];
        
        callbackBlock(NO, errorMessage, -1);
    }];
}

-(void)resendVerificationToEmail:(NSString *)email andCallbackBlock:(void (^) (BOOL success))callbackBlock
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", nil];

    [self postPath:@"resend_verification" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogInfo(@"Resend verification successfully :%@",responseObject);
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        DDLogInfo(@"Resend verification error :%@",error);

        
        
        callbackBlock(NO);
    }];
}

#pragma mark - Foursquare API

/**
 Find the nearby possible locations.
 */

- (void)findNearbyLocationsWithLatitude:(double)lat andLongitude:(double)lon withCallbackBlock:(void (^) (BOOL success, NSArray *locations))callbackBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    [params setObject:@"DTWBJ2KCWORXLDX34VW0V5KQRCIMS5UYLOBY1FPOF0CSZFCJ" forKey:@"client_id"];
    [params setObject:@"QAMSRDCTMHLXH0BRLNSY4KBZFU02CHX3Y2RCOG13FEOYQMUH" forKey:@"client_secret"];

    [params setObject:[NSString stringWithFormat:@"%f,%f", lat, lon] forKey:@"ll"];
    
    [params setObject:[DateFormatterHelper generateStringDateForFSFormat] forKey:@"v"];
    
    [params setObject:@(10) forKey:@"limit"];
    
    AFHTTPClient *fsClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
    
    [fsClient getPath:@"venues/search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSArray *results = [RemoteParser parseNearbyVenuesWithResponseObject:responseObject];
        
        callbackBlock(YES, results);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
        
    }];
}

- (void)findCurrentLocationWithName:(NSString *)name withCallbackBlock:(void (^) (BOOL success, NSArray *locations))callbackBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@"DTWBJ2KCWORXLDX34VW0V5KQRCIMS5UYLOBY1FPOF0CSZFCJ" forKey:@"client_id"];
    [params setObject:@"QAMSRDCTMHLXH0BRLNSY4KBZFU02CHX3Y2RCOG13FEOYQMUH" forKey:@"client_secret"];
    
    [params setObject:@"Stanford, CA, United States" forKey:@"near"];
    
//    [params setObject:@"global" forKey:@"intent"];

    
    [params setObject:name forKey:@"query"];
    
//    [params setObject:@"4d4b7105d754a06372d81259" forKey:@"categoryId"];
    
    [params setObject:[DateFormatterHelper generateStringDateForFSFormat] forKey:@"v"];
    
    [params setObject:@(50) forKey:@"limit"];
    
//    [params setObject:@"students" forKey:@"query"];
    
    AFHTTPClient *fsClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
    
    [fsClient getPath:@"venues/explore" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *results = [RemoteParser parseNearbyVenuesWithResponseLocationsObject:responseObject];
        
        DDLogDebug(@"Exlpore results found by name: %@", results);
        
        callbackBlock(YES, results);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
        
    }];
}

/**
 Find location more accurate.
 */

- (void)findCurrentLocationWithLatitude:(double)lat andLongitude:(double)lon withCallbackBlock:(void (^) (BOOL success, NSArray *locations))callbackBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@"DTWBJ2KCWORXLDX34VW0V5KQRCIMS5UYLOBY1FPOF0CSZFCJ" forKey:@"client_id"];
    [params setObject:@"QAMSRDCTMHLXH0BRLNSY4KBZFU02CHX3Y2RCOG13FEOYQMUH" forKey:@"client_secret"];
    
    [params setObject:[NSString stringWithFormat:@"%f,%f", lat, lon] forKey:@"ll"];
    
    [params setObject:[DateFormatterHelper generateStringDateForFSFormat] forKey:@"v"];
    
    [params setObject:@(1) forKey:@"limit"];
    
//    [params setObject:@"match" forKey:@"intent"];
    
    AFHTTPClient *fsClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
    
    [fsClient getPath:@"venues/search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *results = [RemoteParser parseNearbyVenuesWithResponseObject:responseObject];
        
        callbackBlock(YES, results);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
        
    }];
}

#pragma mark - Push notifications

- (void)registerPushToken:(NSString *)pushToken authParams:(NSDictionary *)authParams callback:(void (^)(BOOL success))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:authParams];
    params[@"type"] = @"ios";
    params[@"device_id"] = pushToken;
    
    [self postPath:@"devices" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO);
    }];
}

-(void)unregisterPushToken:(NSString*)pushToken authParams:(NSDictionary *)authParams callback:(void (^)(BOOL success))callback;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:authParams];
    NSString *path = [NSString stringWithFormat:@"devices/%@", pushToken];
    
    [self deletePath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(YES);
    }];
}



#pragma mark - Posts

- (void)getPostsAfter:(GLPPost *)post withCategoryTag:(NSString*)tag callback:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];
    if(post) {
        params[@"before"] = [NSNumber numberWithInteger:post.remoteKey];
    }
    
    if(tag)
    {
        params[@"filter"] = tag;
    }
    
    [self getPath:@"posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];
        callbackBlock(YES, posts);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)createPost:(GLPPost *)post callbackBlock:(void (^)(BOOL success, int remoteKey))callbackBlock
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:post.content, @"text", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
//    if(post.categories > 0)
//    {
        [params addEntriesFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:[RemoteParser parseCategoriesToTags:post.categories], @"tags", nil]];
//    }

    
    
    //TODO: add a new param url rather than call second method after the post request.
    
    if(post.video.pendingKey)
    {
        [params setObject:post.video.pendingKey forKey:@"video"];
    }
    
    if(post.dateEventStarts)
    {
        [params setObject:[DateFormatterHelper dateUnixFormat:post.dateEventStarts] forKey:@"event-time"];
        [params setObject:post.eventTitle forKey:@"title"];
    }
    
    if(post.location)
    {
        [params setObject:[NSString stringWithFormat:@"%lf,%lf", post.location.latitude, post.location.longitude] forKey:@"location-gps"];
        
        [params setObject:post.location.name forKey:@"location-name"];
        [params setObject:post.location.address forKey:@"location-desc"];
    }
    
    if([post isPollPost])
    {
        [params setObject:[RemoteParser generatePollOptionsInCDFormatWithOptions:post.poll.options] forKey:@"poll-options"];
        //Add the new time comes from poll.
        [params setObject:[DateFormatterHelper dateUnixFormat:post.poll.expirationDate] forKey:@"poll-expiry"];

//        [params setObject:[DateFormatterHelper dateUnixFormat:[DateFormatterHelper addHours:5 toDate:[NSDate date]]] forKey:@"poll-expiry"];
    }
    
    DDLogDebug(@"Create Post params: %@, Categories: %@", params, post.categories);

    
    [self postPath:[self pathForPost:post] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //Get the post id. If user has ulpoaded an image execute the createImagePost method.
        int postRemoteKey = [RemoteParser parseIdFromJson:responseObject];
        
        if(post.imagesUrls!=nil)
        {
            //Create image post.
            [self uploadImage:[post.imagesUrls objectAtIndex:0] withPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success) {
               
                if(success)
                {
                    callbackBlock(YES,postRemoteKey);
                }
                else
                {
                    callbackBlock(NO, -1);
                }
                
                
            }];
        }
        else
        {
            callbackBlock(YES, postRemoteKey);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        callbackBlock(NO, -1);
    }];
}

- (NSString *)pathForPost:(GLPPost *)post
{
    if(post.group)
    {
        return [NSString stringWithFormat:@"networks/%ld/posts", (long)post.group.remoteKey];
    }
    else
    {
        return @"posts";
    }
}

- (void)editPost:(GLPPost *)editedPost callbackBlock:(void (^)(BOOL success, GLPPost *updatedPost))callbackBlock
{
    NSMutableDictionary *params = self.sessionManager.authParameters.mutableCopy;
    
    [params setObject:editedPost.content forKey:@"text"];
    
    if(editedPost.video.pendingKey)
    {
        [params setObject:editedPost.video.pendingKey forKey:@"video"];
    }
    
    if(editedPost.eventTitle)
    {
        [params setObject:editedPost.eventTitle forKey:@"title"];
    }
    
    if(editedPost.location)
    {
        [params setObject:[NSString stringWithFormat:@"%lf,%lf", editedPost.location.latitude, editedPost.location.longitude] forKey:@"location-gps"];
        
        [params setObject:editedPost.location.name forKey:@"location-name"];
        [params setObject:editedPost.location.address forKey:@"location-desc"];
    }
    
    if([editedPost imagePost])
    {
        [params setObject:editedPost.imagesUrls[0] forKey:@"url"];
    }
    
    NSString *path = [NSString stringWithFormat:@"posts/%ld", (long)editedPost.remoteKey];
    
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPPost *newEditedPost = [RemoteParser parsePostFromJson:responseObject];
        newEditedPost.pendingInEditMode = YES;
        
        DDLogDebug(@"WebClient : after edit post %@, actual post %@", responseObject, newEditedPost);
                
        callbackBlock(YES, newEditedPost);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);

    }];

}

-(void)getPostWithRemoteKey:(NSInteger)remoteKey withCallbackBlock:(void (^) (BOOL success, GLPPost *post))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/", (int)remoteKey];

    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        GLPPost *post = [RemoteParser parsePostFromJson:responseObject];
        
        callbackBlock(YES, post);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
        callbackBlock(NO, nil);
    }];
}

-(void)getEventPostsAfterDate:(NSDate*)date withCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock
{    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[DateFormatterHelper dateUnixFormat:date], @"after", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self getPath:@"live" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];

        callbackBlock(YES, posts);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);

    }];
    
}

- (void)getAttendingEventsForUserWithRemoteKey:(NSInteger)userRemoteKey callback:(void (^) (BOOL success, NSArray *posts))callback
{
    NSString *path = [NSString stringWithFormat:@"user/%ld/attending", (long)userRemoteKey];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *attendingPosts = [RemoteParser parsePostsFromJson:responseObject];
                
        callback(YES, attendingPosts);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        callback(NO, nil);
        
    }];
}

- (void)getAttendingEventsAfter:(GLPPost *)post withUserRemoteKey:(NSInteger)userRemoteKey callback:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];
    
    if(post)
    {
        params[@"before"] = [NSNumber numberWithInteger:post.remoteKey];
    }
    
    NSString *path = [NSString stringWithFormat:@"user/%ld/attending", (long)userRemoteKey];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *attendingPosts = [RemoteParser parsePostsFromJson:responseObject];
        callbackBlock(YES, attendingPosts);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
    }];
}

- (void)getCommentsForPost:(GLPPost *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%ld/comments", (long)post.remoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"start", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *comments = [RemoteParser parseCommentsFromJson:responseObject forPost:post];
        callbackBlock(YES, comments);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];

}

- (void)createComment:(GLPComment *)comment callbackBlock:(void (^)(BOOL success))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/comments", comment.post.remoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: comment.content, @"text", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        comment.remoteKey = [RemoteParser parseIdFromJson:responseObject];
        
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

-(void)postLike:(BOOL)like forPostRemoteKey:(NSInteger)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%ld/likes", (long)postRemoteKey];
    
    NSString* liked = [NSString stringWithFormat:@"%@",(like?@"true":@"false")];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: liked, @"liked", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

-(void)loadUserPostsAfter:(GLPPost *)post withRemoteKey:(int)remoteKey callbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.authParameters];
    
    if(post)
    {
        [params setObject:@(post.remoteKey) forKey:@"before"];
    }
    
    
    NSString *path = [NSString stringWithFormat:@"user/%d/posts",remoteKey];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];
        callbackBlock(YES, posts);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
        
    }];
}


- (void)deletePostWithRemoteKey:(NSInteger)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    
    NSString *path = [NSString stringWithFormat:@"posts/%ld", (long)postRemoteKey];
    
    [self deletePath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO);
    }];
    
}

- (void)reportPostWithRemoteKey:(NSInteger)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:[NSNumber numberWithInteger:postRemoteKey] forKey:@"post"];
    
    [self postPath:@"reports" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogInfo(@"Post with %ld id reported successfully.", (long)postRemoteKey);
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO);
    }];
}

- (void)loadAttendeesWithPostRemoteKey:(NSInteger)postRemoteKey callback:(void (^)(NSArray *users, BOOL success))callback
{
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:self.sessionManager.authParameters];

    NSString *path = [NSString stringWithFormat:@"posts/%ld/attendees", (long)postRemoteKey];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSArray *users = [RemoteParser parseAttendeesFromJson:responseObject];
        
        callback(users, YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callback(nil, NO);

    }];
}

#pragma mark - Voting

- (void)voteWithPostRemoteKey:(NSInteger)postRemoteKey andOption:(NSInteger)option callbackBlock:(void (^) (BOOL success, NSString *statusMsg))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%ld/votes", (long)postRemoteKey];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:@(option) forKey:@"option"];
    
    DDLogDebug(@"WebClient : voteWithPostRemoteKey params %@", params);
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES, @"success");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString *errorMessage = [RemoteParser parsePollVotingErrorMessage:error.localizedRecoverySuggestion];
        callbackBlock(NO, errorMessage);
    }];
}

#pragma mark - Campus Live

-(void)attendEvent:(BOOL)attend withPostRemoteKey:(NSInteger)postRemoteKey callbackBlock:(void (^) (BOOL success, NSInteger popularity))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%ld/attendees", (long)postRemoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:(attend) ? @"true" : @"false" forKey:@"attending"];
    
    
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger popularity = [RemoteParser parseNewPopularity:responseObject];
        
        DDLogDebug(@"New Popularity: %ld", (long)popularity);
        
        callbackBlock(YES, popularity);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        callbackBlock(NO, 0);
    }];
}

- (void)campusLiveSummaryUntil:(NSDate *)until callbackBlock:(void (^) (BOOL success, GLPLiveSummary *liveSummary))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"live_summary"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];

    [params setObject:[DateFormatterHelper dateUnixFormat:until] forKey:@"until"];
    [params setObject:[DateFormatterHelper dateUnixFormat:[NSDate date]] forKey:@"after"];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        callbackBlock(YES, [RemoteParser parseLiveSummaryWithJson:responseObject]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
        
    }];
    
}

//TODO: DEPRECATED.
-(void)postAttendInPostWithRemoteKey:(int)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/attending", postRemoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogInfo(@"Attendance added in post id: %d", postRemoteKey);

        
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"Error attending event.");

        callbackBlock(NO);
    }];
}

//TODO: DEPRECATED.
-(void)removeAttendFromPostWithRemoteKey:(int)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/attending", postRemoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    [self deletePath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogInfo(@"Attendance removed with post id: %d", postRemoteKey);
        
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"Error removing attendance.");
        
        callbackBlock(NO);
    }];
}


#pragma mark - Groups

-(void)getGroupDescriptionWithId:(NSInteger)groupId withCallbackBlock:(void (^) (BOOL success, GLPGroup *group, NSString *errorMessage))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"networks/%ld",(long)groupId];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPGroup *group = [RemoteParser parseGroupFromJson:responseObject];
        
        
        callbackBlock(YES, group, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString *errorMessage = [RemoteParser parseLoadingGroupErrorMessage:error.localizedRecoverySuggestion];
        
        callbackBlock(NO, nil, errorMessage);
        
    }];
}

-(void)getGroupswithCallbackBlock:(void (^) (BOOL success, NSArray *groups))callbackBlock
{
    [self getPath:@"profile/networks" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *groups = [RemoteParser parseGroupsFromJson:responseObject];
        
        callbackBlock(YES, groups);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
    }];
}

-(void)getMembersWithGroupRemoteKey:(int)remoteKey withCallbackBlock:(void (^) (BOOL success, NSArray *members))callbackBlock
{
    
    NSString *path = [NSString stringWithFormat:@"networks/%d/users",remoteKey];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
        NSArray *members = [RemoteParser parseMembersFromJson:responseObject withGroupRemoteKey:remoteKey];
        
        
        callbackBlock(YES, members);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
    }];
}

- (void)makeMemberAsAdmin:(GLPMember *)member withCallbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"networks/%d/admins", member.groupRemoteKey];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[SessionManager sharedInstance] authParameters]];
    
    [params setObject:@(member.remoteKey) forKey:@"users"];

    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogInfo(@"Member %@ become an administrator %@.", member, responseObject);
                
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        callbackBlock(NO);
    }];
}

- (void)removeMemberFromAdmin:(GLPMember *)member withCallbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"networks/%d/admins/%d", member.groupRemoteKey, member.remoteKey];
    
    [self deletePath:path parameters:[[SessionManager sharedInstance] authParameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogInfo(@"Member %@ removed from being an administrator.", member);
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO);

    }];
}

-(void)getPostsAfter:(GLPPost *)post withGroupId:(NSInteger)groupId callback:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];
    
    if(post)
    {
        params[@"before"] = [NSNumber numberWithInteger:post.remoteKey];
    }
    
    NSString *path = [NSString stringWithFormat:@"networks/%ld/posts",(long)groupId];

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];
        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject withGroupRemoteKey:groupId];

        callbackBlock(YES, posts);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
    }];
}

-(void)createGroupWithGroup:(GLPGroup *)group callback:(void (^) (BOOL success, GLPGroup *group))callbackBlock
{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:group.name forKey:@"name"];
    
    if(group.groupImageUrl)
    {
        [params setObject:group.groupImageUrl forKey:@"url"];
    }
    
    if(group.groupDescription)
    {
        [params setObject:group.groupDescription forKey:@"desc"];
    }
    
    
    [params setObject:[group privacyToString] forKey:@"privacy"];
    
    
    [self postPath:@"networks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPGroup *group = [RemoteParser parseGroupFromJson:responseObject];
        group.membersCount = 1;
        callbackBlock(YES, group);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);

        
    }];
}

-(void)quitFromAGroupWithRemoteKey:(NSInteger)groupRemoteKey callback:(void (^) (BOOL success))callbackBlock
{
    
    NSString *path = [NSString stringWithFormat:@"profile/networks/%ld", (long)groupRemoteKey];
    
    
    
    [self deletePath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        callbackBlock(NO);
        
    }];
}

-(void)getPostsGroupsFeedWithTag:(NSString *)tag callback:(void (^) (BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];

    if(tag)
    {
        params[@"filter"] = tag;
    }
    
    
    [self getPath:@"profile/networks/posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *posts = [RemoteParser parsePostsGroupFromJson:responseObject];
        
        callbackBlock(YES, posts);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
    }];
}

- (void)addUsers:(NSArray *)users toGroup:(GLPGroup *)group callback:(void (^)(BOOL success, GLPGroup *updatedGroup))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    params[@"users"] = [users componentsJoinedByString:@","];
    
    NSString *path = [NSString stringWithFormat:@"networks/%d/users", group.remoteKey];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogDebug(@"Webclient : addUsers %@", responseObject);
        
        GLPGroup *updatedGroup = [RemoteParser parseGroupFromJson:responseObject];
        callback(YES, updatedGroup);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}

- (void)joinPublicGroup:(GLPGroup *)group callback:(void (^) (BOOL success, GLPGroup *updatedGroup))callback
{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];

    NSArray *user = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", [SessionManager sharedInstance].user.remoteKey], nil];
    
    [self addUsers:user toGroup:group callback:callback];
    
}

- (void)searchGroupsWithName:(NSString *)groupName callback:(void (^) (BOOL success, NSArray *groups))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    NSString *path = [NSString stringWithFormat:@"search/groups/%@", groupName];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *groups = [RemoteParser parseGroupsFromJson:responseObject];
        
        callback(YES, groups);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callback(NO, nil);
        
    }];
    
}

- (void)searchGroupsWithUsersRemoteKey:(NSInteger)usersRemoteKey callback:(void (^) (BOOL success, NSArray *groups))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];

    NSString *path = [NSString stringWithFormat:@"user/%ld/networks", (long)usersRemoteKey];
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSArray *groups = [RemoteParser parseGroupsFromJson:responseObject];
        
        callback(YES, groups);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callback(NO, nil);
        
    }];

}

//TODO: Redundant code with add users and add users to group. (total 3 methods)

-(void)inviteUsersViaFacebookWithGroupRemoteKey:(int)groupRemoteKey andUsersFacebookIds:(NSArray *)fbIds withCallbackBlock:(void (^) (BOOL success))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    params[@"fbusers"] = [fbIds componentsJoinedByString:@","];
    
    NSString *path = [NSString stringWithFormat:@"networks/%d/users", groupRemoteKey];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogDebug(@"After facebook invitations: %@", responseObject);
        
        callback(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogDebug(@"After facebook invitations ERROR: %@", error);
        
        callback(NO);
    }];
}

/* CONVERSATIONS */

//- (void)getConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock
//{
//    [self getPath:@"conversations" parameters:self.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSArray *conversations = [JsonParser parseConversationsFromJson:responseObject ignoringUserKey:self.sessionManager.key];
//        callbackBlock(YES, conversations);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        callbackBlock(NO, nil);
//    }];
//}

#pragma mark - Conversations


- (void)getConversationsFilterByLive:(BOOL)live withCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock
{
    [self getPath:@"conversations" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *conversations = [RemoteParser parseConversationsFilterByLive:live fromJson:responseObject];
        callbackBlock(YES, conversations);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)getConversationForRemoteKey:(NSInteger)remoteKey withCallback:(void (^)(BOOL success, GLPConversation *conversation))callback
{
    NSString *path = [NSString stringWithFormat:@"conversations/%d", remoteKey];
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        GLPConversation *conversation = [RemoteParser parseConversationFromJson:responseObject];
        callback(YES, conversation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}

// Synchronous operation
- (void)synchronousGetConversationForRemoteKey:(NSInteger)remoteKey withCallback:(void (^)(BOOL success, GLPConversation *conversation))callback
{
    NSString *path = [NSString stringWithFormat:@"conversations/%d", remoteKey];
    [self executeSynchronousRequestWithMethod:@"GET" path:path params:self.sessionManager.authParameters callback:^(BOOL success, id json) {
        if(!success) {
            callback(NO, nil);
            return;
        }
                
        GLPConversation *conversation = [RemoteParser parseConversationFromJson:json];
        callback(YES, conversation);
    }];
}

// Synchronous operation
- (void)synchronousGetConversationsFilterByLive:(BOOL)live withCallback:(void (^)(BOOL success, NSArray *conversations))callback
{
    [self executeSynchronousRequestWithMethod:@"GET" path:@"conversations" params:self.sessionManager.authParameters callback:^(BOOL success, id json) {
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        NSArray *conversations = [RemoteParser parseConversationsFilterByLive:YES fromJson:json];
        
        DDLogDebug(@"Conversations: %@", conversations);
        callback(YES, conversations);
    }];
}

- (void)getLastMessagesForConversation:(GLPConversation *)conversation withLastMessage:(GLPMessage *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock
{
//    [self addLatency];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"start", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    if(lastMessage) {
        [params setObject:[NSNumber numberWithInteger:lastMessage.remoteKey] forKey:@"after"];
    }
    
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", conversation.remoteKey];
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *messages = [RemoteParser parseMessagesFromJson:responseObject forConversation:conversation];
        callbackBlock(YES, messages);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //TODO: TEMP FIX
        callbackBlock(YES, nil);
        //callbackBlock(NO, nil);
    }];

}

- (NSArray *)synchronousGetMessagesForConversation:(GLPConversation *)conversation after:(GLPMessage *)afterMessage before:(GLPMessage *)beforeMessage
{
    NSInteger beforeRemoteKey = beforeMessage ? beforeMessage.remoteKey : NSNotFound;
    NSInteger afterRemoteKey = afterMessage ? afterMessage.remoteKey : NSNotFound;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"start", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    if(afterRemoteKey != NSNotFound) {
        [params setObject:[NSNumber numberWithInteger:afterRemoteKey] forKey:@"after"];
    }
    
    if(beforeRemoteKey != NSNotFound) {
        [params setObject:[NSNumber numberWithInteger:beforeRemoteKey] forKey:@"before"];
    }
    
    NSString *path = [NSString stringWithFormat:@"conversations/%ld/messages", (long)conversation.remoteKey];
    
    __block NSArray *result = nil;
    
    [self executeSynchronousRequestWithMethod:@"GET" path:path params:params callback:^(BOOL success, id json) {
        if(!success) {
            return;
        }
        
        result = [RemoteParser parseMessagesFromJson:json forConversation:conversation];
    }];
    
    return result;
}

- (void)getMessagesForConversation:(GLPConversation *)conversation after:(GLPMessage *)afterMessage before:(GLPMessage *)beforeMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock
{
    NSInteger before = beforeMessage ? beforeMessage.remoteKey : NSNotFound;
    NSInteger after = afterMessage ? afterMessage.remoteKey : NSNotFound;
    
    [self getMessagesForConversation:conversation afterRemoteKey:after beforeRemoteKey:before callbackBlock:callbackBlock];
}

- (void)getMessagesForConversation:(GLPConversation *)conversation afterRemoteKey:(NSInteger)afterRemoteKey beforeRemoteKey:(NSInteger)beforeRemoteKey callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"start", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    if(afterRemoteKey != NSNotFound) {
        [params setObject:[NSNumber numberWithInteger:afterRemoteKey] forKey:@"after"];
    }
    
    if(beforeRemoteKey != NSNotFound) {
        [params setObject:[NSNumber numberWithInteger:beforeRemoteKey] forKey:@"before"];
    }
    
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", conversation.remoteKey];
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"response Object %@", responseObject);
        NSArray *messages = [RemoteParser parseMessagesFromJson:responseObject forConversation:conversation];
        callbackBlock(YES, messages);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //TODO: TEMP FIX
        //callbackBlock(YES, nil);
        callbackBlock(NO, nil);
    }];
    
}


- (void)getPreviousMessagesBefore:(GLPMessage *)message callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:message.remoteKey], @"before", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", message.conversation.remoteKey];
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *messages = [RemoteParser parseMessagesFromJson:responseObject forConversation:message.conversation];
        callbackBlock(YES, messages);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //TODO: TEMP FIX
        callbackBlock(YES, nil);
        //callbackBlock(NO, nil);
    }];
    
}

- (void)deleteConversationWithRemoteKey:(NSInteger)remoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    NSString *path = [NSString stringWithFormat:@"conversations/%ld",(long)remoteKey];
    
    [self deletePath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogInfo(@"Conversation with remote key deleted: %ld", (long)remoteKey);
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"Conversation could not be deleted: %@", error.description);
        
        callbackBlock(NO);

    }];
}

#pragma mark - Live conversations

- (void)getConversationsWithCallback:(void (^)(BOOL success, NSArray *conversations))callbackBlock
{
    [self getPath:@"conversations" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *conversations = [RemoteParser parseConversationsFromJson:responseObject];
        callbackBlock(YES, conversations);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)getLiveConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock
{
    [self getPath:@"conversations/live" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *conversations = [RemoteParser parseConversationsFromJson:responseObject];
        callbackBlock(YES, conversations);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}


/**
 Find all the live conversations and return only the last three.
 
 */

//- (void)getLiveConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock
//{
//    [self getPath:@"conversations" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSArray *conversations = [RemoteParser parseConversationsFilterByLive:YES fromJson:responseObject];
//        
//        //Choose the last three conversations and sort them by expiration date.
//        conversations = [RemoteParser orderAndGetLastThreeConversations:conversations];
//        
//        callbackBlock(YES, conversations);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        callbackBlock(NO, nil);
//    }];
//}

- (void)getLastMessagesForLiveConversation:(GLPLiveConversation *)conversation withLastMessage:(GLPMessage *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"start", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    if(lastMessage) {
        [params setObject:[NSNumber numberWithInteger:lastMessage.remoteKey] forKey:@"after"];
    }
    
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", conversation.remoteKey];
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *messages = [RemoteParser parseMessagesFromJson:responseObject forLiveConversation:conversation];
        callbackBlock(YES, messages);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //TODO: TEMP FIX
        callbackBlock(YES, nil);
        //callbackBlock(NO, nil);
    }];
    
}

//- (void)getMessagesForConversation:(OldConversation *)conversation withCallbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock
//{
//    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", conversation.key];
//    [self getPath:path parameters:self.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSArray *messages = [JsonParser parseMessagesFromJson:responseObject];
////        if(responseObject != (id)[NSNull null] && json.count != 0) {
////            messages =
////        } else {
////            messages = [NSArray array];
////        }
//        
//        callbackBlock(YES, messages);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        callbackBlock(NO, nil);
//    }];
//}

//- (void)createOneToOneConversationWithCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock
//{
//    [self createConversationWithPath:@"newconversation" andCallbackBlock:callbackBlock];
//}
//
//- (void)createGroupConversationWithCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock
//{
//    [self createConversationWithPath:@"newgroupconversation" andCallbackBlock:callbackBlock];
//}

- (GLPConversation *)synchronousCreateConversationWithUser:(GLPUser *)user
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    if(ENV_FAKE_LIVE_CONVERSATIONS) {
        params[@"random"] = @"false";
        
        NSString *userIds;
        if(self.sessionManager.user.remoteKey == 15) {
            userIds = @"8";
        } else {
            userIds = @"15";
        }
        
        params[@"participants"] = userIds;
        DDLogInfo(@"Generate fake live conversation for current user: %d, with opponent user: %@", self.sessionManager.user.remoteKey, userIds);
    } else {
        if(!user) {
            params[@"random"] = @"true";
            params[@"participant_count"] = @2;
        } else {
            params[@"random"] = @"false";
            params[@"participants"] = [NSString stringWithFormat:@"%d", user.remoteKey];
        }
    }
    
    __block GLPConversation *conversation = nil;

    [self executeSynchronousRequestWithMethod:@"POST" path:@"conversations" params:params callback:^(BOOL success, id json) {
        if(!success) {
            return;
        }
        
        @try {
            conversation = [RemoteParser parseConversationFromJson:json];
        } @catch (NSException *e) {
            DDLogInfo(@"Parse conversation expcetion for json: %@", json);
            conversation = nil;
        }
    }];
    
    return conversation;
}

- (GLPConversation *)synchronousCreateConversationWithUsers:(NSArray *)users
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    params[@"random"] = @"false";
    params[@"participants"] = [RemoteParser generateParticipandsUserIdFormat:users];

    __block GLPConversation *conversation = nil;

    [self executeSynchronousRequestWithMethod:@"POST" path:@"conversations" params:params callback:^(BOOL success, id json) {
        if(!success) {
            return;
        }
        
        @try {
            conversation = [RemoteParser parseConversationFromJson:json];
        } @catch (NSException *e) {
            DDLogInfo(@"Parse conversation expcetion for json: %@", json);
            conversation = nil;
        }
    }];
    
    return conversation;
    
}

- (void)createConversation:(void (^)(GLPConversation *conversation))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    if(ENV_FAKE_LIVE_CONVERSATIONS) {
        params[@"random"] = @"false";
        
        NSString *userIds;
        if(self.sessionManager.user.remoteKey == 15) {
            userIds = @"8";
        } else {
            userIds = @"15";
        }
        
        params[@"participants"] = userIds;
        DDLogInfo(@"Generate fake live conversation for current user: %d, with opponent user: %@", self.sessionManager.user.remoteKey, userIds);
    } else {
        params[@"random"] = @"true";
        params[@"participant_count"] = @2;
    }
    
    [self postPath:@"conversations" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPConversation *conversation = nil;
        @try {
            conversation = [RemoteParser parseConversationFromJson:responseObject];
        } @catch (NSException *e) {
            DDLogInfo(@"Parse conversation expcetion for json: %@", responseObject);
        }
        
        callback(conversation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil);
    }];
}


- (void)createConversationWithPath:(NSString *)path andCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock
{
    [self postPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        GLPConversation *conversation = [RemoteParser parseConversationFromJson:responseObject];
        
        callbackBlock(YES, conversation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

-(void)createRegularConversationWithUserRemoteKey:(int)remoteKey andCallback:(void (^) (BOOL sucess, GLPConversation *conversation ))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"false", @"random",[NSString stringWithFormat:@"%d",remoteKey], @"participants", nil];
    
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:@"conversations" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPConversation *conversation = [RemoteParser parseConversationFromJson:responseObject];
                
        callbackBlock(YES, conversation);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogDebug(@"ERROR: %@", error);

        
        callbackBlock(NO, nil);
    }];
    
}


#pragma mark - Messages

// Blocking operation
- (void)createMessageSynchronously:(GLPMessage *)message callback:(void (^)(BOOL success, NSInteger remoteKey))callback
{
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", message.conversation.remoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:message.content, @"text", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self executeSynchronousRequestWithMethod:@"POST" path:path params:params callback:^(BOOL success, id json) {
        if(!success) {
            callback(NO, NSNotFound);
            return;
        }
        
        callback(YES, [json[@"id"] integerValue]);
    }];
}


- (void)longPollNewMessagesForConversation:(GLPConversation *)conversation callbackBlock:(void (^)(BOOL success, GLPMessage *message))callbackBlock
{
    [self getPath:@"longpoll" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"long poll %@", responseObject);
        
        GLPMessage *message = [RemoteParser parseMessageFromLongPollJson:responseObject];
        callbackBlock(YES, message);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

// Blocking operation
- (void)synchronousLongPollWithCallback:(void (^)(BOOL success, GLPMessage *message))callback
{
    [self executeSynchronousRequestWithMethod:@"GET" path:@"longpoll" params:self.sessionManager.authParameters callback:^(BOOL success, id json) {
        NSLog(@"long poll response %@", json);
        
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        // empty response
        if(!json[@"conversation_id"]) {
            callback(YES, nil);
            return;
        }
        
        GLPConversation *conversation = [[GLPConversation alloc] init];
        conversation.remoteKey = [json[@"conversation_id"] integerValue];
        conversation.title = json[@"by"][@"username"];
        
        GLPMessage *message = [RemoteParser parseMessageFromJson:json forConversation:nil];
        message.conversation = conversation;
        
        callback(YES, message);
    }];
}


/* USER */

#pragma mark - User

- (void)getUserWithKey:(NSInteger)key authParams:(NSDictionary *)authParams callbackBlock:(void (^)(BOOL success, GLPUser *user))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"user/%d", key];
    
    [self getPath:path parameters:authParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        GLPUser *user = [RemoteParser parseUserFromJson:responseObject];
        callbackBlock(YES, user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)getUserWithKey:(NSInteger)key callbackBlock:(void (^)(BOOL success, GLPUser *user))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"user/%d", key];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPUser *user = [RemoteParser parseUserFromJson:responseObject];
        
        callbackBlock(YES, user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}


-(void)addContact:(int)contactRemoteKey callbackBlock:(void (^)(BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",contactRemoteKey], @"user", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:@"contacts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Contact added with server's response: %@",responseObject);
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //TODO: Handle error message.
        
        DDLogError(@"Error adding user: %@", error.localizedDescription);
        
        callbackBlock(NO);
    }];
}

-(void)changePasswordWithOld:(NSString*)oldPass andNew:(NSString*)newPass callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:oldPass, @"old", newPass, @"new", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:@"profile/change_pass" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
        callbackBlock(NO);
    }];
}

-(void)changeNameWithName:(NSString*)name andSurname:(NSString*)surname callbackBlock:(void (^) (BOOL success))callbackBlock
{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"first", surname, @"last", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:@"profile/name" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogDebug(@"FAILED: %@", error);
        
        callbackBlock(NO);
    }];
}

- (void)changeTagLine:(NSString *)tagline callback:(void (^) (BOOL success))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:tagline forKey:@"tagline"];
    
    [self postPath:@"profile/tagline" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callback(YES);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        callback(NO);
        
    }];
}

-(void)resetPasswordWithEmail:(NSString *)email callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", nil];
    
    [self postPath:@"profile/request_reset" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogDebug(@"RESPONSE: %@", responseObject);
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogDebug(@"FAILED: %@", error);
        
        callbackBlock(NO);
    }];
    
}

/**
 
 NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:notification.remoteKey] forKey:@"seen"];
 [params addEntriesFromDictionary:self.sessionManager.authParameters];
 
 [self putPath:@"notifications" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
 NSArray *notifications = [RemoteParser parseNotificationsFromJson:responseObject];
 callback(YES, notifications);
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 callback(NO, nil);
 }];
 */
-(void)acceptContact:(int)contactRemoteKey callbackBlock:(void (^)(BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"true" forKey:@"accepted"];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    NSString* path = [NSString stringWithFormat:@"contacts/%d",contactRemoteKey];
    
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Contact Accepted: %@", responseObject);
        
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Problem accepting the contact: %@",error.description);
        
        callbackBlock(NO);
    }];
    
    
}

#pragma mark - User's pending posts

- (void)getPostsWaitingForApprovalCallbackBlock:(void (^) (BOOL success, NSArray *pendingPosts))callbackBlock
{
    [self getPath:@"profile/pending" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
        callbackBlock(YES, [RemoteParser parsePendingPostsFromJson:responseObject]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);

    }];
}

#pragma mark - Approval

- (void)getApprovalStatusCallbackBlock:(void (^) (BOOL success, NSInteger level))callbackBlock
{
    [self getPath:@"approve/level" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger level = [RemoteParser parseApprovalLevel:responseObject];
        
        callbackBlock(YES, level);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, -1);
        
    }];
}

#pragma mark - Busy free status

-(void)setBusyStatus:(BOOL)busy callbackBlock:(void (^)(BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",(busy)?@"true":@"false"], @"status", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:@"profile/busy" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

-(void)getBusyStatus:(void (^) (BOOL success, BOOL status))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"profile/busy"];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        //Parse busy status.
        BOOL busy = [RemoteParser parseBusyStatus:responseObject];
        
        callbackBlock(YES,busy);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO,NO);

    }];
    
}

#pragma mark - Contacts

-(void)getContactsForUser:(GLPUser *)user authParams:(NSDictionary *)authParams callback:(void (^)(BOOL success, NSArray *contacts))callback;
{
    NSString* path = [NSString stringWithFormat:@"contacts"];
    
    [self getPath:path parameters:authParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *contacts = [RemoteParser parseContactsFromJson:responseObject];
        callback(YES, contacts);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}

-(void)getContactsWithCallback:(void (^)(BOOL success, NSArray *contacts))callback;
{
    NSString* path = [NSString stringWithFormat:@"contacts"];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *contacts = [RemoteParser parseContactsFromJson:responseObject];
        callback(YES, contacts);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}

#pragma mark - Image


-(void)uploadImage:(NSString *)url withPostRemoteKey:(int)postRemoteKey callbackBlock:(void (^)(BOOL))callbackBlock
{
    NSString* path = [NSString stringWithFormat:@"posts/%d/images",postRemoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:url, @"url", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

-(void)uploadImageToProfileUser:(NSString *)url callbackBlock:(void (^)(BOOL))callbackBlock
{
    NSString* path = [NSString stringWithFormat:@"profile/profile_image"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:url, @"url", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    NSLog(@"PARAMS BEFORE SETTING AN IMAGE: %@", params);
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR UPLOAD IMAGE FOR PROFILE: %@", error.description);
        callbackBlock(NO);
    }];
}

-(void)uploadImage:(NSData *)imageData callback:(void (^)(BOOL success, NSString *imageUrl))callback
{
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"upload" parameters:self.sessionManager.authParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:[NSString stringWithFormat:@"user_id_%d_image.png", self.sessionManager.user.remoteKey] mimeType:@"image/png"];
    }];
    
    [request setTimeoutInterval:300];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sentt %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"upload image response %@", responseObject);
        
        NSString *response = [RemoteParser parseImageUrl:(NSDictionary*)operation.responseString];
        callback(YES, response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

/**
 Now only is used for uploading an image in chat.
 */
-(void)uploadImage:(NSData *)imageData callback:(void (^)(BOOL success, NSString *imageUrl))callback progressCallBack:(void (^) (CGFloat progress))progressCallback
{
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"upload" parameters:self.sessionManager.authParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:[NSString stringWithFormat:@"user_id_%ld_image.png", (long)self.sessionManager.user.remoteKey] mimeType:@"image/png"];
    }];
    
    [request setTimeoutInterval:300];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {        
        progressCallback((CGFloat)totalBytesWritten / (CGFloat )totalBytesExpectedToWrite);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"upload image response %@", responseObject);
        
        NSString *response = [RemoteParser parseImageUrl:(NSDictionary*)operation.responseString];
        callback(YES, response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)uploadGroupImage:(NSData *)imageData withTimestamp:(NSDate *)timestamp callback:(void (^)(BOOL success, NSString *imageUrl))callback
{

    
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"upload" parameters:self.sessionManager.authParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSInteger groupKey = [[GLPLiveGroupManager sharedInstance] getPendingGroupKeyWithTimestamp:timestamp];
        
        [[GLPLiveGroupManager sharedInstance] registerUploadingGroup];
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:[NSString stringWithFormat:@"user_id_%d_image.png", self.sessionManager.user.remoteKey] mimeType:@"image/png"];
    }];
    
    [request setTimeoutInterval:300];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sentt %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        NSInteger groupKey = [[GLPLiveGroupManager sharedInstance] getPendingGroupKeyWithTimestamp:timestamp];
        NSString *notificationName = [NSString stringWithFormat:@"%ld_%@", (long)groupKey, GLPNOTIFICATION_NEW_GROUP_IMAGE_PROGRESS];
        DDLogDebug(@"WebClient : notification name %@", notificationName);

        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:@{@"uploaded_progress" : [NSNumber numberWithFloat:(float)totalBytesWritten/(float)totalBytesExpectedToWrite]}];
        
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"upload image response %@", responseObject);
        
        NSString *response = [RemoteParser parseImageUrl:(NSDictionary*)operation.responseString];
        callback(YES, response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSInteger groupKey = [[GLPLiveGroupManager sharedInstance] getPendingGroupKeyWithTimestamp:timestamp];

        [[GLPLiveGroupManager sharedInstance] unregisterUploadingGroup];
        
        callback(NO, nil);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}


-(void)uploadImage:(NSData*)image ForUserRemoteKey:(int)userRemoteKey callbackBlock: (void (^)(BOOL success, NSString *response)) callbackBlock
{
 
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"image", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];


    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[SessionManager sharedInstance] serverPath]]];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"upload" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        [formData appendPartWithFileData:image name:@"image" fileName:[NSString stringWithFormat:@"user_id_%d_image.png",userRemoteKey] mimeType:@"image/png"];
    }];

    
   [request setTimeoutInterval:300];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // if you want progress updates as it's uploading, uncomment the following:
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        NSDictionary *progressData = [[NSDictionary alloc] initWithObjectsAndKeys:@(totalBytesWritten), @"data_written", @(totalBytesExpectedToWrite), @"data_expected", nil];
        
        //That means that the user tries to change his/her image.
        if(userRemoteKey == [SessionManager sharedInstance].user.remoteKey)
        {
            //Inform GLPProgressManager.
            [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CHANGE_IMAGE_PROGRESS object:self userInfo:progressData];
        }
        else
        {
            //This should be executed when the user tries to change group image.
            [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CHANGE_GROUP_IMAGE_PROGRESS object:self userInfo:progressData];
        }
     }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        NSString *response = [RemoteParser parseImageUrl:(NSDictionary*)operation.responseString];

        
        callbackBlock(YES, response);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"RESPONSE ERROR: %@", error.description);
        callbackBlock(NO, nil);
        
    }];
    
    
    [httpClient enqueueHTTPRequestOperation:operation];
}

- (void)uploadImage:(NSData *)imageData forGroupWithRemoteKey:(NSInteger)groupRemoteKey callback:(void (^)(BOOL success, NSString *imageUrl))callback
{
    NSDate *timestamp = [[GLPLiveGroupManager sharedInstance] timestampWithGroupRemoteKey:groupRemoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:imageData, @"image", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[SessionManager sharedInstance] serverPath]]];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"upload" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:[NSString stringWithFormat:@"group_id%d_image.png",groupRemoteKey] mimeType:@"image/png"];
    }];
    
    
    [request setTimeoutInterval:300];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // if you want progress updates as it's uploading, uncomment the following:
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        NSDictionary *progressData = [[NSDictionary alloc] initWithObjectsAndKeys:@(totalBytesWritten), @"data_written", @(totalBytesExpectedToWrite), @"data_expected", nil];
        
   
        NSDate *nowTimestamp = [[GLPLiveGroupManager sharedInstance] timestampWithGroupRemoteKey:groupRemoteKey];
        
        if([timestamp isEqualToDate:nowTimestamp])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_CHANGE_GROUP_IMAGE_PROGRESS object:self userInfo:progressData];
        }
    }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response = [RemoteParser parseImageUrl:(NSDictionary*)operation.responseString];
        
        NSDate *nowTimestamp = [[GLPLiveGroupManager sharedInstance] timestampWithGroupRemoteKey:groupRemoteKey];
        
        if([timestamp isEqualToDate:nowTimestamp])
        {
            callback(YES, response);
        }
        else
        {
            callback(YES, @"");
        }
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"RESPONSE ERROR: %@", error.description);
        callback(NO, nil);
        
    }];
    
    
    [httpClient enqueueHTTPRequestOperation:operation];}


-(void)uploadImageUrl:(NSString *)imageUrl withGroupRemoteKey:(int)remoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:imageUrl forKey:@"url"];
    
    NSString *path = [NSString stringWithFormat:@"networks/%d", remoteKey];
    
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO);
    }];
}

#pragma mark - Video

//TODO: Deprecated.

-(void)uploadVideo:(NSData *)videoData callback:(void (^)(BOOL success, NSString *videoUrl))callback
{
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"upload" parameters:self.sessionManager.authParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:videoData name:@"video" fileName:[NSString stringWithFormat:@"user_id_%ld_video.mp4", (long)self.sessionManager.user.remoteKey] mimeType:@"application/mp4"];
    }];
    
    [request setTimeoutInterval:300];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        DDLogInfo(@"Sent video %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response = [RemoteParser parseImageUrl:(NSDictionary*)operation.responseString];
        callback(YES, response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)uploadVideoWithData:(NSData *)videoData withTimestamp:(NSDate *)timestamp callback:(void (^)(BOOL success, NSNumber *videoId))callback
{
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"videos" parameters:self.sessionManager.authParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:videoData name:@"video" fileName:[NSString stringWithFormat:@"user_id_%ld_video.mp4", (long)self.sessionManager.user.remoteKey] mimeType:@"video/mp4"];
    }];
    
    [request setTimeoutInterval:300];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {

        NSDictionary *notificationDict = [self generateDictionaryWithExpectedBytes:totalBytesExpectedToWrite withCurrentBytes:totalBytesWritten andTimestamp:timestamp];
        
        [self updateCampusWallProgressBarIfNeededWithNotificationDict:notificationDict];

        [self updateGroupProgressBarIfNeededWithNotificationDict:notificationDict];
        
        [self updatePendingPostProgressBarIfNeededWithNotificationDict:notificationDict];
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *videoKey = [RemoteParser parseVideoResponse:responseObject];
        
        callback(YES, videoKey);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callback(NO, nil);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)updateCampusWallProgressBarIfNeededWithNotificationDict:(NSDictionary *)notificationDict
{
    long totalBytesExpectedToWrite = [self parseExpectedBytesToWriteWithNotificationDict:notificationDict];
    long totalBytesWritten = [self parseBytesWrittenWithNotificationDict:notificationDict];
    NSDate *timestamp = [self parseTimestampWithNotificationDict:notificationDict];
    
    if([[[GLPVideoPostCWProgressManager sharedInstance] registeredTimestamp] isEqualToDate:timestamp])
    {
        
        DDLogDebug(@"CampusWall progress manager timestamp %@ and current one %@",[[GLPVideoPostCWProgressManager sharedInstance] registeredTimestamp], timestamp);
        
        //Inform GLPCampusWallProgressManager.
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_VIDEO_PROGRESS_UPDATE object:self userInfo:notificationDict];
        
        
        
    }
    else if(totalBytesExpectedToWrite == totalBytesWritten)
    {
        //Inform GLPCampusWallProgressManager that the video is uploaded and now is started processed.
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_VIDEO_PROGRESS_UPLOADING_COMPLETED object:self userInfo:@{@"timestamp": timestamp}];
    }
}

- (void)updateGroupProgressBarIfNeededWithNotificationDict:(NSDictionary *)notificationDict
{
    long totalBytesExpectedToWrite = [self parseExpectedBytesToWriteWithNotificationDict:notificationDict];
    long totalBytesWritten = [self parseBytesWrittenWithNotificationDict:notificationDict];
    NSDate *timestamp = [self parseTimestampWithNotificationDict:notificationDict];

    if ([[[GLPLiveGroupPostManager sharedInstance] registeredTimestamp] isEqualToDate:timestamp])
    {
        
        NSString *notificationName = [[GLPLiveGroupPostManager sharedInstance] generateNSNotificationNameForPendingGroupPost];
        
        
        DDLogDebug(@"Group progress manager timstamp %@ and current one %@. Notification name: %@",[[GLPLiveGroupPostManager sharedInstance] registeredTimestamp], timestamp, notificationName);
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:notificationDict];
    }
    else if(totalBytesExpectedToWrite == totalBytesWritten)
    {
        NSString *notificationName = [[GLPLiveGroupPostManager sharedInstance] generateNSNotificationUploadFinshedNameForPendingGroupPost];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:notificationDict];
    }
}

- (void)updatePendingPostProgressBarIfNeededWithNotificationDict:(NSDictionary *)notificationDict
{
    long totalBytesExpectedToWrite = [self parseExpectedBytesToWriteWithNotificationDict:notificationDict];
    long totalBytesWritten = [self parseBytesWrittenWithNotificationDict:notificationDict];
    NSDate *timestamp = [self parseTimestampWithNotificationDict:notificationDict];
    
    if([[[GLPPendingPostsManager sharedInstance] registeredTimestamp] isEqualToDate:timestamp])
    {        
        //Inform GLPVideoPendingPostProgressManager.
        [[NSNotificationCenter defaultCenter] postNotificationName:[[GLPPendingPostsManager sharedInstance] generateNSNotificationNameForPendingPost] object:self userInfo:notificationDict];
    }
    else if(totalBytesExpectedToWrite == totalBytesWritten)
    {
        //Inform GLPVideoPendingPostProgressManager that the video is uploaded and now is started processing.
        [[NSNotificationCenter defaultCenter] postNotificationName:[[GLPPendingPostsManager sharedInstance] generateNSNotificationUploadFinshedNameForPendingPost] object:self userInfo:@{@"timestamp": timestamp}];
    }
}

- (long)parseExpectedBytesToWriteWithNotificationDict:(NSDictionary *)notificationDict
{
    NSDictionary *progressData = [notificationDict objectForKey:@"update"];
    
    NSNumber *bytesExpected = progressData[@"data_expected"];
    
    return bytesExpected.longValue;
}

- (long)parseBytesWrittenWithNotificationDict:(NSDictionary *)notificationDict
{
    NSDictionary *progressData = [notificationDict objectForKey:@"update"];
    
    NSNumber *bytesWritten = progressData[@"data_written"];
    
    return bytesWritten.longValue;
}

- (NSDate *)parseTimestampWithNotificationDict:(NSDictionary *)notficationDict
{
    return [notficationDict objectForKey:@"timestamp"];
}

- (NSDictionary *)generateDictionaryWithExpectedBytes:(long long)expectedBytes withCurrentBytes:(long long)currentBytes andTimestamp:(NSDate *)timestamp
{
    NSMutableDictionary *finalDictNotification = [[NSMutableDictionary alloc] init];
    
    NSDictionary *progressData = [[NSDictionary alloc] initWithObjectsAndKeys:@(currentBytes), @"data_written", @(expectedBytes), @"data_expected", nil];
    
    [finalDictNotification setObject:progressData forKey:@"update"];
    
    [finalDictNotification setObject:timestamp forKey:@"timestamp"];
    
    return finalDictNotification;
}

- (void)checkForReadyVideoWithPendingVideoKey:(NSNumber *)videoKey callback:(void (^) (BOOL success, GLPVideo *result))callback
{
    NSString *path = [NSString stringWithFormat:@"videos/%@", videoKey];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPVideo *video = [RemoteParser parseVideoData:responseObject];
        
        callback(YES, video);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}

#pragma mark - Notifications

-(void)getUnreadNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback
{
    [self getPath:@"notifications" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *items = [RemoteParser parseNotificationsFromJson:responseObject];
        callback(YES, items);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}

- (void)getAllNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"include_seen"];
    
    [self getPath:@"notifications" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *items = [RemoteParser parseNotificationsFromJson:responseObject];
        callback(YES, items);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}

-(void)synchronousGetNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback
{
    [self executeSynchronousRequestWithMethod:@"GET" path:@"notifications" params:self.sessionManager.authParameters callback:^(BOOL success, id json) {
        
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        NSArray *items = [RemoteParser parseNotificationsFromJson:json];
        callback(YES, items);
    }];
}

- (void)markNotificationsRead:(void (^)(BOOL success))callback
{
    DDLogInfo(@"Mark all notifications read");
    
    [self putPath:@"notifications" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DDLogInfo(@"Mark notifications read success: %@",responseObject);
        
        if(callback) {
            callback(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"Mark notifications read failure: %@", [error description]);
        if(callback) {
            callback(NO);
        }
    }];
}


- (void)markNotificationsReadWithLastNotificationRemoteKey:(int)remoteKey withCallbackBlock:(void (^)(BOOL success))callback
{
    DDLogInfo(@"Mark all notifications read");
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:[NSNumber numberWithInt:remoteKey] forKey:@"seen"];
    
    [self putPath:@"notifications" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"Mark notifications read success.");
        
        if(callback) {
            callback(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"Mark notifications read failure: %@", [error description]);
        if(callback) {
            callback(NO);
        }
    }];
}

- (void)markConversationsRead:(void (^)(BOOL success))callback
{
    DDLogInfo(@"Mark all conversations read");
    
    [self postPath:@"conversations/read_all" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"Mark conversations read success");
        
        if(callback) {
            callback(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"Mark notifications read failure: %@", [error description]);
        if(callback) {
            callback(NO);
        }
    }];
}

- (void)markConversationWithRemoteKeyAsRead:(NSInteger)convRemoteKey upToMessageWithRemoteKey:(NSInteger)msgRemoteKey callback:(void (^)(BOOL success))callback
{
    NSString *path = [NSString stringWithFormat:@"conversations/%ld/messages", (long)convRemoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:@(msgRemoteKey) forKey:@"seen"];
    
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogInfo(@"Conversation %ld up to message %ld marked as read.", (long)convRemoteKey, (long)msgRemoteKey);
        
//        DDLogDebug(@"RESPONSE FROM SERVER: %@", responseObject);
        
        callback(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        DDLogInfo(@"Conversation %ld up to message %ld not marked as read.", (long)convRemoteKey, (long)msgRemoteKey);

        
    }];
}



- (void)markNotificationRead:(GLPNotification *)notification callback:(void (^)(BOOL success, NSArray *notifications))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:notification.remoteKey] forKey:@"seen"];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self putPath:@"notifications" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *notifications = [RemoteParser parseNotificationsFromJson:responseObject];
        callback(YES, notifications);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}


# pragma mark - Users

- (void)searchUserByName:(NSString *)name callback:(void (^)(NSArray *users))callback
{
    NSString *finalNameSurname = [RemoteParser generateServerUserNameTypeWithNameSurname:name];
    
    NSString *path = [NSString stringWithFormat:@"search/users/%@", finalNameSurname];
    [self getPath:path parameters:_sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"search: %@", responseObject);
        NSArray *users = [RemoteParser parseUsersFromJson:responseObject];
        callback(users);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callback(nil);
    }];
}

# pragma mark - Utils

- (void)executeSynchronousRequestWithMethod:(NSString *)method path:(NSString *)path params:(NSDictionary *)params callback:(void (^)(BOOL success, id json))callback
{
    DDLogInfo(@"Start synchronous request %@ - %@...", method, path);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:params];
    DDLogInfo(@"Url: %@", request.URL);
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    DDLogInfo(@"Synchronous %@ - %@ finished with result: %d", method, path, error ? NO : YES);
    
    if(error) {
        DDLogError(@"Request error %@", [error localizedDescription]);
        callback(NO, nil);
        return;
    }
    
    error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // this may happen but im not sure why
    if(error) {
        NSString* content = [NSString stringWithUTF8String:[data bytes]];
        DDLogError(@"Error parsing json response to dictionary: %@ - Problematic content: %@", error.localizedDescription, content);
        callback(NO, nil);
        return;
    }
    
    // this should not happen
//    if(!json) {
//        DDLogError(@"Json response to dictionary is null");
//        callback(NO, nil);
//        return;
//    }
    
    callback(YES, json);
}


#pragma mark - Invite Message
- (void)getInviteMessageWithCallback:(void (^)(BOOL success, NSString *inviteMessage))callback {
    
    [self getPath:@"invite_message" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"RESPONSE OBJECT: %@",responseObject);
        
        NSString *message = [RemoteParser parseMessageFromJson:responseObject];
        callback(YES, message);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
    }];
}

# pragma mark - Helper methods

// DEBUG use only
// Setting the max concurrent operations to 1 may break other things such as requests running in "background" and in parallel (long polling request for instance)
- (void)addLatency
{
    DDLogWarn(@"WARNING MESSAGE - ADD 2 SEC LATENCY TO REQUEST");
    [self.operationQueue setMaxConcurrentOperationCount:1];
    [self.operationQueue addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:2];
    }];
}

@end
