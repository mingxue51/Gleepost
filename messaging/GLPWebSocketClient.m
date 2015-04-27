//
//  GLPWebSocketClient.m
//  Gleepost
//
//  Created by Lukas on 1/21/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPWebSocketClient.h"
#import "GLPMessageProcessor.h"
#import "SessionManager.h"
#import "GLPNetworkManager.h"

@interface GLPWebSocketClient()

@property (strong, nonatomic) SRWebSocket *webSocket;

@end

@implementation GLPWebSocketClient

@synthesize webSocket=_webSocket;

static GLPWebSocketClient *instance = nil;

+ (GLPWebSocketClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPWebSocketClient alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    return self;
}

#pragma mark - Web socket

- (void)startWebSocket
{
    DDLogInfo(@"Start web socket");
    
    if(_webSocket && (_webSocket.readyState == SR_CONNECTING || _webSocket.readyState == SR_OPEN)) {
        DDLogInfo(@"Start web socket cannot start because web socket is already in opening or opened, abort");
        return;
    }
    
    SessionManager *sessionManager = [SessionManager sharedInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@ws?id=%ld&token=%@", GLP_TEST_SERVER_URL, (long)sessionManager.user.remoteKey, sessionManager.token];
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

- (void)sendMessageWithJson:(NSData *)data
{
    if(_webSocket.readyState == SR_CLOSING || _webSocket.readyState == SR_CLOSED || _webSocket.readyState == SR_CONNECTING)
    {
        DDLogInfo(@"Send message via web socket cannot be completed because the web socket is in closing state or closed, abort");
        return;
    }
    
    [_webSocket send:data];
}

# pragma mark - Web socket delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)response
{
    DDLogInfo(@"Web socket received response: %@", response);
    [[GLPMessageProcessor sharedInstance] processWebSocketMessage:response];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    DDLogInfo(@"Web socket did open");
    [[GLPNetworkManager sharedInstance] webSocketDidConnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Web socket did fail with error: %@", error);
    [[GLPNetworkManager sharedInstance] webSocketDidFail];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"Web socket did close with code: %d, reason: %@, was clean: %d", code, reason, wasClean);
    [[GLPNetworkManager sharedInstance] webSocketDidClose];
}


@end
