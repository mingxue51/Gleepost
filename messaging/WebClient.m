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
#import "GLPWebSocketMessageProcessor.h"

@interface WebClient()

@property (strong, nonatomic) SessionManager *sessionManager;
@property (strong, nonatomic) SRWebSocket *webSocket;

@property (assign, nonatomic) BOOL networkStatusEvaluated; // controls if the network available status has been evaluated at least once

@end

@implementation WebClient

@synthesize isNetworkAvailable;
@synthesize webSocket=_webSocket;

static NSString * const kWebserviceBaseUrl = @"https://gleepost.com/api/v0.24/";

static WebClient *instance = nil;

+ (WebClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WebClient alloc] initWithBaseURL:[NSURL URLWithString:kWebserviceBaseUrl]];
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
        
        // start / stop the websocket accordly
        if(available) {
            [self startWebSocketIfLoggedIn];
        } else {
            [self stopWebSocket];
        }
        
        NSLog(@"Network status changed, currently available: %d", self.isNetworkAvailable);
    }
}

- (void)activate
{
    [self updateNetworkAvailableStatus:self.networkReachabilityStatus];
}



- (void)loginWithName:(NSString *)name password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, GLPUser *user, NSString *token, NSDate *expirationDate))callbackBlock
{
    // ios6 temp fix
    if(!name || !password) {
        callbackBlock(NO, nil, nil, nil);
        return;
    }
    
    [self postPath:@"login" parameters:@{@"user": name, @"pass": password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = (NSDictionary *) responseObject;
        
        GLPUser *user = [[GLPUser alloc] init];
        user.remoteKey = [json[@"id"] integerValue];
        user.name = name;

        NSString *token = json[@"value"];
        NSDate *expirationDate = [RemoteParser parseDateFromString:json[@"expiry"]];
        
        callbackBlock(YES, user, token, expirationDate);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil, nil, nil);
    }];
}

- (void)registerWithName:(NSString *)name email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, NSString* responseObject, int userRemoteKey))callbackBlock
{
    [self postPath:@"register" parameters:@{@"user": name, @"pass": password, @"email": email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response during registration: %@", responseObject);
        int remotekey = [RemoteParser parseIdFromJson:responseObject];
        
        callbackBlock(YES, responseObject, remotekey);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
       NSLog(@"ERROR DURING REGISTRATION: %@", [RemoteParser parseRegisterErrorMessage:error.localizedRecoverySuggestion]);
        
        NSString *errorMessage = [RemoteParser parseRegisterErrorMessage:error.localizedRecoverySuggestion];
        
        callbackBlock(NO, errorMessage, -1);
    }];
}

- (void)registerPushToken:(NSString *)pushToken callback:(void (^)(BOOL success))callback
{
    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];
    params[@"type"] = @"ios";
    params[@"device_id"] = pushToken;
    
    [self postPath:@"devices" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"push register response: %@", responseObject);
        callback(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO);
    }];
}



#pragma mark - Posts

- (void)getPostsAfter:(GLPPost *)post callback:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [self.sessionManager.authParameters mutableCopy];
    if(post) {
        params[@"before"] = [NSNumber numberWithInt:post.remoteKey];
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
        
    [self postPath:@"posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //Get the post id. If user has ulpoaded an image execute the createImagePost method.
        int postRemoteKey = [RemoteParser parseIdFromJson:responseObject];
        
        if(post.imagesUrls!=nil)
        {
            //Create image post.
            [self uploadImage:[post.imagesUrls objectAtIndex:0] withPostRemoteKey:postRemoteKey callbackBlock:^(BOOL success) {
               
                if(success)
                {
                    NSLog(@"Image posted!");
                    
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

//-(void)upload

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
        
        NSLog(@"RESPONSE FROM LIKE:%@",responseObject);
        
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
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
    [self executeSynchronousRequestWithMethod:@"GET" path:path callback:^(BOOL success, id json) {
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
    [self executeSynchronousRequestWithMethod:@"GET" path:@"conversations" callback:^(BOOL success, id json) {
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

/**
 Find all the live conversations and return only the last three.
 
 */

- (void)getLiveConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock
{
    [self getPath:@"conversations" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *conversations = [RemoteParser parseConversationsFilterByLive:YES fromJson:responseObject];
        
        //Choose the last three conversations and sort them by expiration date.
        conversations = [RemoteParser orderAndGetLastThreeConversations:conversations];
        
        callbackBlock(YES, conversations);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

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

- (void)createConversationWithCallback:(void (^)(BOOL success, GLPConversation *conversation))callback
{
    [self postPath:@"newconversation" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        GLPConversation *conversation = [RemoteParser parseConversationFromJson:responseObject];
        callback(YES, conversation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO, nil);
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


#pragma mark - Messages

- (void)createMessage:(GLPMessage *)message callbackBlock:(void (^)(BOOL success, NSInteger remoteKey))callbackBlock
{
    NSString *path = nil;
    
    if(!message.conversation)
    {
        path = [NSString stringWithFormat:@"conversations/%d/messages", message.liveConversation.remoteKey];
    }
    else
    {
        path = [NSString stringWithFormat:@"conversations/%d/messages", message.conversation.remoteKey];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:message.content, @"text", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = responseObject;
        callbackBlock(YES, [json[@"id"] integerValue]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, 0);
    }];
}

// Blocking operation
- (void)createMessageSynchronously:(GLPMessage *)message callbackBlock:(void (^)(BOOL success, NSInteger remoteKey))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", message.conversation.remoteKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:message.content, @"text", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:params];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error) {
        callbackBlock(NO, 0);
    } else {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        callbackBlock(YES, [json[@"id"] integerValue]);
    }
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
    [self executeSynchronousRequestWithMethod:@"GET" path:@"longpoll" callback:^(BOOL success, id json) {
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
        NSLog(@"PROFILE USER: %@",user.profileImageUrl);
        
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


    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kWebserviceBaseUrl]];
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


#pragma mark - Notifications

-(void)synchronousGetNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback
{
    [self executeSynchronousRequestWithMethod:@"GET" path:@"notifications" callback:^(BOOL success, id json) {
        
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        NSArray *items = [RemoteParser parseNotificationsFromJson:json];
        callback(YES, items);
    }];
}

/**
 
 Mark notifications as read from the current notification and older.
 
 */
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



#pragma mark - Utils

- (void)executeSynchronousRequestWithMethod:(NSString *)method path:(NSString *)path callback:(void (^)(BOOL success, id json))callback
{
    NSLog(@"Start synchronous request %@ - %@...", method, path);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:self.sessionManager.authParameters];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Synchronous %@ - %@ finished with result: %d", method, path, error ? NO : YES);
    
    if(error) {
        callback(NO, nil);
        return;
    }
    
    error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // this may happen but im not sure why
    if(error) {
        NSString* content = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"Error parsing json response to dictionary: %@ - Problematic content: %@", error.localizedDescription, content);
        callback(NO, nil);
        return;
    }
    
    // this should not happen
    if(!json) {
        NSLog(@"Json response to dictionary is null");
        callback(NO, nil);
        return;
    }
    
    callback(YES, json);
}


#pragma mark - Web socket

- (void)startWebSocketIfLoggedIn
{
    DDLogInfo(@"Start web socket if logged in");
    
    if(![self.sessionManager isSessionValid]) {
        DDLogInfo(@"Start web socket cannot start because session is not valid, try to close web socket");
        [_webSocket close];
        return;
    }
    
    if(_webSocket && (_webSocket.readyState == SR_CONNECTING || _webSocket.readyState == SR_OPEN)) {
        DDLogInfo(@"Start web socket cannot start because web socket is already in opening or opened, abort");
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@ws?id=%d&token=%@", kWebserviceBaseUrl, self.sessionManager.user.remoteKey, self.sessionManager.token];
    NSLog(@"Init web socket with url: %@", url);
    
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
    _webSocket.delegate = self;
    
    [_webSocket open];
}

- (void)stopWebSocket
{
    DDLogInfo(@"Stop web socket");
    
    // web socket not yet initialized
    if(!_webSocket) {
        DDLogInfo(@"Stop web socket cannot stop because web socket is nil, abort");
        return;
    }
    
    if(_webSocket.readyState == SR_CLOSING || _webSocket.readyState == SR_CLOSED) {
        DDLogInfo(@"Stop web socket cannot stop because web socket already in closing or closed, abort");
        _webSocket = nil;
        return;
    }
    
    [_webSocket close];
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)response
{
    NSLog(@"Web socket received response: %@", response);
    [[GLPWebSocketMessageProcessor sharedInstance] processMessage:response];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Web socket did open");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Web socket did fail with error: %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"Web socket did close with code: %d, reason: %@, was clean: %d", code, reason, wasClean);
}


# pragma mark - Helper methods

// DEBUG use only
// Setting the max concurrent operations to 1 may break other things such as requests running in "background" and in parallel (long polling request for instance)
- (void)addLatency
{
    NSLog(@"WARNING MESSAGE - ADD 2 SEC LATENCY TO REQUEST");
    [self.operationQueue setMaxConcurrentOperationCount:1];
    [self.operationQueue addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:2];
    }];
}

@end
