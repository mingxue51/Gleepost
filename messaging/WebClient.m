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
        instance = [[WebClient alloc] initWithBaseURL:[NSURL URLWithString:GLP_BASE_URL]];
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

//- (void)getPostsAfter:(GLPPost *)post callback:(void (^)(BOOL success, NSArray *posts))callbackBlock
//{
//    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];
//    if(post) {
//        params[@"before"] = [NSNumber numberWithInt:post.remoteKey];
//    }
//    
//    [self getPath:@"posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];
//        callbackBlock(YES, posts);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        callbackBlock(NO, nil);
//    }];
//}

- (void)getPostsAfter:(GLPPost *)post withCategoryTag:(NSString*)tag callback:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];
    if(post) {
        params[@"before"] = [NSNumber numberWithInt:post.remoteKey];
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
    [params addEntriesFromDictionary:[NSMutableDictionary dictionaryWithObjectsAndKeys:[RemoteParser parseCategoriesToTags:post.categories], @"tags", nil]];
    
    
    if(post.dateEventStarts)
    {
//        NSString *attribs = [NSString stringWithFormat:@"event-time,%@,title,%@",[DateFormatterHelper dateUnixFormat:post.dateEventStarts], post.eventTitle];
//        
//        [params addEntriesFromDictionary:[NSMutablefDictionary dictionaryWithObjectsAndKeys:attribs, @"attribs", nil]];
        
        [params setObject:[DateFormatterHelper dateUnixFormat:post.dateEventStarts] forKey:@"event-time"];
        [params setObject:post.eventTitle forKey:@"title"];
    }
    
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

-(NSString *)pathForPost:(GLPPost *)post
{
    if(post.group)
    {
        return [NSString stringWithFormat:@"networks/%d/posts", post.group.remoteKey];
    }
    else
    {
        return @"posts";
    }
}


///**
// Call this mehtod when you need to create a new post that is event.
// 
// @param post
// @param date
// 
// */
//-(void)createPost:(GLPPost *)post withDate:(NSDate *)date callbackBlock:(void (^)(BOOL success, int remoteKey))callbackBlock
//{
//    
//}

-(void)getPostWithRemoteKey:(int)remoteKey withCallbackBlock:(void (^) (BOOL success, GLPPost *post))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/", remoteKey];
    
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        GLPPost *post = [RemoteParser parseIndividualPostFromJson:responseObject];
        
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

- (void)getCommentsForPost:(GLPPost *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/comments", post.remoteKey];
    
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

-(void)postLike:(BOOL)like forPostRemoteKey:(int)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/likes", postRemoteKey];
    
    NSString* liked = [NSString stringWithFormat:@"%@",(like?@"true":@"false")];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: liked, @"liked", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

-(void)userPostsWithRemoteKey:(int)remoteKey callbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock
{
    
    NSString *path = [NSString stringWithFormat:@"user/%d/posts",remoteKey];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];
        callbackBlock(YES, posts);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
        
    }];
}

#pragma mark - Campus Live

-(void)userAttendingLivePostsWithCallbackBlock:(void (^) (BOOL success, NSArray *postsIds))callbackBlock
{
    NSString *path = @"profile/attending";
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *posts = [RemoteParser parseLivePostsIds:responseObject];
        callbackBlock(YES, posts);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
        
    }];
}

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

-(void)getGroupDescriptionWithId:(int)groupId withCallbackBlock:(void (^) (BOOL success, GLPGroup *group))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"networks/%d",groupId];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPGroup *group = [RemoteParser parseGroupFromJson:responseObject];
        
        
        callbackBlock(YES, group);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
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
        
        NSArray *members = [RemoteParser parseUsersFromJson:responseObject];
        
        
        callbackBlock(YES, members);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
    }];
}

-(void)getPostsAfter:(GLPPost *)post withGroupId:(int)groupId callback:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];
    
    if(post)
    {
        params[@"before"] = [NSNumber numberWithInt:post.remoteKey];
    }
    
    NSString *path = [NSString stringWithFormat:@"networks/%d/posts",groupId];

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];
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
    
    
    DDLogDebug(@"Group to be created: %@", group);
    
    [self postPath:@"networks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPGroup *group = [RemoteParser parseGroupFromJson:responseObject];
        
        callbackBlock(YES, group);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);

        
    }];
}

-(void)quitFromAGroupWithRemoteKey:(int)groupRemoteKey callback:(void (^) (BOOL success))callbackBlock
{
    
    NSString *path = [NSString stringWithFormat:@"profile/networks/%d", groupRemoteKey];
    
    
    
    [self deletePath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        callbackBlock(NO);
        
    }];
}

-(void)getPostsGroupsFeedWithCallbackBlock:(void (^) (BOOL success, NSArray *posts))callbackBlock
{
    
    [self getPath:@"profile/networks/posts" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *posts = [RemoteParser parsePostsGroupFromJson:responseObject];
        
        callbackBlock(YES, posts);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callbackBlock(NO, nil);
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
    
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", conversation.remoteKey];
    
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

/**
- (void)getPostsWithCallbackBlock:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"start", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self getPath:@"posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];
        NSLog(@"PARAMS: %@", params);
        callbackBlock(YES, posts);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}
*/
 

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
        
        DDLogDebug(@"RESPONSE: %@", responseObject);
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogDebug(@"FAILED: %@", error);
        
        callbackBlock(NO);
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


-(void)uploadImage:(NSData*)image ForUserRemoteKey:(int)userRemoteKey callbackBlock: (void (^)(BOOL success, NSString *response)) callbackBlock
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"image", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];


    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:GLP_BASE_URL]];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"upload" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        [formData appendPartWithFileData:image name:@"image" fileName:[NSString stringWithFormat:@"user_id_%d_image.png",userRemoteKey] mimeType:@"image/png"];
    }];

    
   [request setTimeoutInterval:300];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // if you want progress updates as it's uploading, uncomment the following:
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
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


-(void)uploadImageUrl:(NSString *)imageUrl withGroupRemoteKey:(int)remoteKey callbackBlock:(void (^) (BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    
    [params setObject:imageUrl forKey:@"url"];
    
    NSString *path = [NSString stringWithFormat:@"networks/%d", remoteKey];
    
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogDebug(@"Response after changing group image: %@", responseObject);
        
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        
        
    }];
    
}


#pragma mark - Notifications

-(void)getNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback
{
    [self getPath:@"notifications" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        DDLogInfo(@"Mark notifications read success: %@",responseObject);
        
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
    NSString *path = [NSString stringWithFormat:@"search/users/%@", name];
    [self getPath:path parameters:_sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"search: %@", responseObject);
        NSArray *users = [RemoteParser parseUsersFromJson:responseObject];
        callback(users);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil);
    }];
}


# pragma mark - Groups

- (void)addUsers:(NSArray *)users toGroup:(GLPGroup *)group callback:(void (^)(BOOL success))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.sessionManager.authParameters];
    params[@"users"] = [users componentsJoinedByString:@","];
    
    NSString *path = [NSString stringWithFormat:@"networks/%d/users", group.remoteKey];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO);
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
        DDLogCInfo(@"RESPONSE OBJECT: %@",responseObject);
        
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
