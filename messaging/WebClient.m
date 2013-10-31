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

@interface WebClient()

@property (strong, nonatomic) SessionManager *sessionManager;

@end

@implementation WebClient

static NSString * const kWebserviceBaseUrl = @"https://gleepost.com/api/v0.16/";

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

-(void)logout
{
    [[SessionManager sharedInstance] logout];
    
    //Navigate to the first page of the app.
    
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

- (void)registerWithName:(NSString *)name email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, NSString* responceMessage))callbackBlock
{
    [self postPath:@"register" parameters:@{@"user": name, @"pass": password, @"email": email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response during registration: %@", responseObject);
        
        callbackBlock(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
       NSLog(@"ERROR DURING REGISTRATION: %@", [RemoteParser parseRegisterErrorMessage:error.localizedRecoverySuggestion]);
        
        NSString *errorMessage = [RemoteParser parseRegisterErrorMessage:error.localizedRecoverySuggestion];
        
        callbackBlock(NO, errorMessage);
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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: comment.content, @"text", nil];
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

- (void)createOneToOneConversationWithCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock
{
    [self createConversationWithPath:@"newconversation" andCallbackBlock:callbackBlock];
}

- (void)createGroupConversationWithCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock
{
    [self createConversationWithPath:@"newgroupconversation" andCallbackBlock:callbackBlock];
}

/**
 Create a new conversation.
 */
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
 


//- (void)createPost:(GLPPost *)post callbackBlock:(void (^)(BOOL success))callbackBlock
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:post.content, @"text", nil];
//    [params addEntriesFromDictionary:self.sessionManager.authParameters];
//    
//    [self postPath:@"posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        callbackBlock(YES);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        callbackBlock(NO);
//    }];
//}

//id, token, user
-(void)addContact:(int)contactRemoteKey callbackBlock:(void (^)(BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",contactRemoteKey], @"user", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    NSLog(@"Contact PARAMS: %@", params);
    
    [self postPath:@"contacts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callbackBlock(YES);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}



#pragma mark - Contacts

-(void) getContactsWithCallbackBlock:(void (^)(BOOL success, NSArray *contacts))callbackBlock
{
    NSString* path = [NSString stringWithFormat:@"contacts"];
    
    [self getPath:path parameters:self.sessionManager.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *contacts = [RemoteParser parseContactsFromJson:responseObject];
        callbackBlock(YES, contacts);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

#pragma mark - Image


//AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//NSDictionary *parameters = @{@"foo": @"bar"};
//NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
//[manager POST:@"http://example.com/resources.json" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//    [formData appendPartWithFileURL:filePath name:@"image" error:nil];
//} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    NSLog(@"Success: %@", responseObject);
//} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    NSLog(@"Error: %@", error);
//}];


-(void)uploadImage:(NSData*)image ForPost:(GLPPost *)post callbackBlock: (void (^)(BOOL success)) callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"upload"];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"image", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    

    
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData){
        
        
        [formData appendPartWithFormData:image name:@"Image"];
        //[formData appendPartWithFileData:image name:[NSString stringWithFormat:@"file"] fileName:[NSString stringWithFormat:@"avatar_big.png"] mimeType:@"image/png"];
        
    }];
    
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"!!!Response object: %@",responseObject);

    
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failure: %@",error.description);

        callbackBlock(NO);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
    
    
    
    
//    [self postPath:path parameters:params withImage:image success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"!!!Response object: %@",responseObject);
//        
//        callbackBlock(YES);
//
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Failure: %@",error.description);
//        
//        callbackBlock(NO);
//
//    }];
    
    
    
    

    /**__block int i = 0;
    
    NSString *path = [NSString stringWithFormat:@"upload"];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"image", nil];
    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://gleepost.com/api/v0.15/"]];

    
      NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:path parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
       //[formData appendPartWithFileData: image name:@"image" fileName:@"temp.png" mimeType:@"image/png"];
          
//          NSData *imageData = UIImageJPEGRepresentation(image,0.5);
          [formData appendPartWithFileData:image name:[NSString stringWithFormat:@"file%d",i ] fileName:[NSString stringWithFormat:@"abc%d.jpg",i ] mimeType:@"image/png"];

   }];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"response: %@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
    [operation start]; **/
    
    ////////////////
    
//    NSString *path = [NSString stringWithFormat:@"upload"];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"image", nil];
//    [params addEntriesFromDictionary:self.sessionManager.authParameters];
//    
//   // NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:keyParameter, @"keyName", nil];
//    
//    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://gleepost.com/api/v0.15/"]];
//    
//    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:path parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        
//        [formData appendPartWithFileData: image name:@"image" fileName:@"temp.png" mimeType:@"image/png"];
//        
//    }];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
//         NSLog(@"response: %@",jsons);
//         
//     }
//      failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         if([operation.response statusCode] == 403)
//         {
//             NSLog(@"Upload Failed");
//             return;
//         }
//         NSLog(@"error: %@", [operation error]);
//         
//     }];
//    
//    [operation start];

    
    
    
    
    
   // NSString *path = [NSString stringWithFormat:@"upload"];
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"image", nil];
//    //params[@"id"] = [NSString stringWithFormat:@"%d",post.remoteKey];
//    [params addEntriesFromDictionary:self.sessionManager.authParameters];
    
//    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
    
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters withImage:(NSData*)image success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	//NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
   // AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://gleepost.com/api/v0.15/"]];

    
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {

        [formData appendPartWithFileData:image name:[NSString stringWithFormat:@"file"] fileName:[NSString stringWithFormat:@"abc.png"] mimeType:@"image/png"];
        
    }];
    
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

    
//-(void)uploadImage:(NSData*)image ForPost:(GLPPost *)post callbackBlock: (void (^)(BOOL success)) callbackBlock
//{
//    NSString *path = [NSString stringWithFormat:@"upload"];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"image", nil];
//    //params[@"id"] = [NSString stringWithFormat:@"%d",post.remoteKey];
//    [params addEntriesFromDictionary:self.sessionManager.authParameters];
//    
//    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        callbackBlock(YES);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        callbackBlock(NO);
//    }];
//}


@end
