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


@interface WebClient()

@property (strong, nonatomic) SessionManager *sessionManager;

@end

@implementation WebClient

static NSString * const kWebserviceBaseUrl = @"https://gleepost.com/api/v0.13/";

static WebClient *instance = nil;

+ (WebClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WebClient alloc] initWithBaseURL:[NSURL URLWithString:kWebserviceBaseUrl]];
    });
    
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self) {
        return nil;
    }
    
    [self setParameterEncoding:AFFormURLParameterEncoding];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    self.sessionManager = [SessionManager sharedInstance];
    
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [[[WebClient sharedInstance] operationQueue] cancelAllOperations];
            NSLog(@"Network unavailable");
        } else {
            NSLog(@"Network available");
        }
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

- (void)loginWithName:(NSString *)name password:(NSString *)password andCallbackBlock:(void (^)(BOOL success))callbackBlock
{
    // ios6 temp fix
    if(!name || !password) {
        callbackBlock(NO);
        return;
    }
    
    [self postPath:@"login" parameters:@{@"user": name, @"pass": password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = (NSDictionary *) responseObject;
        
        GLPUser *user = [[GLPUser alloc] init];
        user.remoteKey = [json[@"id"] integerValue];
        user.name = name;

        NSString *token = json[@"value"];
        NSDate *expirationDate = [RemoteParser parseDateFromString:json[@"expiry"]];
        
        NSAssert(user.remoteKey != 0, @"");
        NSAssert(token, @"");
        NSAssert(expirationDate, @"");
        
        [self.sessionManager registerUser:(GLPUser *)user withToken:token andExpirationDate:expirationDate];
        
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

- (void)registerWithName:(NSString *)name email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success))callbackBlock
{
    [self postPath:@"register" parameters:@{@"user": name, @"pass": password, @"email": email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

- (void)getPostsWithCallbackBlock:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"start", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self getPath:@"posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *posts = [RemoteParser parsePostsFromJson:responseObject];
        callbackBlock(YES, posts);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)createPost:(GLPPost *)post callbackBlock:(void (^)(BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:post.content, @"text", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
        
    [self postPath:@"posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"text", comment.content, nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)getConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock
{
    [self getPath:@"conversations" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *conversations = [RemoteParser parseConversationsFromJson:responseObject];
        callbackBlock(YES, conversations);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)getLastMessagesForConversation:(GLPConversation *)conversation withLastMessage:(GLPMessage *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock
{
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

- (void)createOneToOneConversationWithCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock
{
    [self createConversationWithPath:@"newconversation" andCallbackBlock:callbackBlock];
}

- (void)createGroupConversationWithCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock
{
    [self createConversationWithPath:@"newgroupconversation" andCallbackBlock:callbackBlock];
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

- (void)createMessage:(GLPMessage *)message callbackBlock:(void (^)(BOOL success, NSInteger remoteKey))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", message.conversation.remoteKey];
    
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

- (void)longPollNewMessageCallbackBlock:(void (^)(BOOL success, GLPMessage *message))callbackBlock
{
    [self getPath:@"longpoll" parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"long poll %@", responseObject);
        NSDictionary *json = responseObject;
        
        //TODO: conversation
        GLPConversation *conversation = [[GLPConversation alloc] init];
        conversation.remoteKey = [json[@"conversation_id"] integerValue];
        conversation.title = json[@"by"][@"username"];
        GLPMessage *message = [RemoteParser parseMessageFromJson:responseObject forConversation:nil];
        message.conversation = conversation;
        
        callbackBlock(YES, message);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}


- (void)cancelMessagesLongPolling
{
    [self cancelAllHTTPOperationsWithMethod:@"GET" path:@"longpoll"];
}


/* USER */

- (void)getUserWithKey:(NSInteger)key callbackBlock:(void (^)(BOOL success, GLPUser *user))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"user/%d", key];
    
    NSLog(@"USER: %@",path);
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GLPUser *user = [RemoteParser parseUserFromJson:responseObject];
        NSLog(@"Callback User: %@",user.name);
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
 


//- (void)getUserWithKey:(NSInteger)key callbackBlock:(void (^)(BOOL success, GLPUser *user))callbackBlock
//{
//    NSString *path = [NSString stringWithFormat:@"user/%d", key];
//    
//    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        GLPUser *user = [RemoteParser parseUserFromJson:responseObject];
//        callbackBlock(YES, user);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        callbackBlock(NO, nil);
//    }];
//}



@end
