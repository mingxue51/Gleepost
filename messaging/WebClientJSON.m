//
//  WebClientJSON.m
//  Gleepost
//
//  Created by Silouanos on 22/12/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//
//  This class handles all requests that expects a JSON-encoded post body.

#import "WebClientJSON.h"
#import "SessionManager.h"
#import "AFJSONRequestOperation.h"
#import "GLPPost.h"
#import "DateFormatterHelper.h"

@interface WebClientJSON ()

@property (assign, nonatomic) BOOL networkStatusEvaluated;

@property (strong, nonatomic) SessionManager *sessionManager;

@end

@implementation WebClientJSON

static WebClientJSON *instance = nil;

+ (WebClientJSON *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DDLogInfo(@"WebClientJSON init %@", [[SessionManager sharedInstance] serverPath]);
        instance = [[WebClientJSON alloc] initWithBaseURL:[NSURL URLWithString:[[SessionManager sharedInstance] serverPath]]];
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
    
//    self.networkStatusEvaluated = NO;
//    self.isNetworkAvailable = NO; // we init with NO and waiting for listener to update the value if the network is up
    self.sessionManager = [SessionManager sharedInstance];

    
    [self setParameterEncoding:AFJSONParameterEncoding];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"X-GP-Auth" value:[NSString stringWithFormat:@"%@-%@", @(self.sessionManager.user.remoteKey), self.sessionManager.token]];
    
    return self;
}

#pragma mark - Views count

- (void)visibleViewsWithPosts:(NSArray *)posts withCallbackBlock:(void (^)(BOOL success))callback
{
    NSMutableArray *postsToSend = [[NSMutableArray alloc] init];
    
    for(GLPPost *p in posts)
    {
        NSDictionary *keyVal = [[NSDictionary alloc] initWithObjectsAndKeys:@(p.remoteKey), @"post", [DateFormatterHelper stringDateServersTypeWithDate:[NSDate date]], @"time",nil];
        
        [postsToSend addObject:keyVal];
    }

    NSMutableURLRequest *jsonRequest = [self requestWithMethod:@"POST" path:@"views/posts" parameters:nil];
    
    NSError *error = nil;
    
    [jsonRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:postsToSend options:0 error:&error]];
    
    NSString* newStr = [[NSString alloc] initWithData:jsonRequest.HTTPBody encoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[SessionManager sharedInstance] serverPath], @"views/posts"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:20];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%@-%@", @(self.sessionManager.user.remoteKey), self.sessionManager.token] forHTTPHeaderField:@"X-GP-Auth"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [newStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        callback(YES);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        callback(NO);
    }];
    
    [jsonOperation setSSLPinningMode:AFSSLPinningModeCertificate];
    
    [jsonOperation start];
    

//    NSMutableURLRequest *jsonRequest = [self requestWithMethod:@"POST" path:@"views/posts" parameters:nil];
//    
//    NSError *error = nil;
//
//    [jsonRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:@[test] options:0 error:&error]];
//
//    DDLogDebug(@"Http body %@", jsonRequest.HTTPBody);
//    
//    NSString* newStr = [[NSString alloc] initWithData:jsonRequest.HTTPBody encoding:NSUTF8StringEncoding];
//
//    DDLogDebug(@"-> %@ %@ %@", @[test], newStr, error);
//    
//    
//    
//    AFHTTPRequestOperation *jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:jsonRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"Success");
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        NSLog(@"Failure %@ Error %@", JSON, error.description);
//    }];
//    
//    
//    [jsonOperation setSSLPinningMode:AFSSLPinningModeCertificate];
//    
//    [jsonOperation start];
    
}


@end
