//
//  GLPNetworkManager.m
//  Gleepost
//
//  Created by Lukas on 1/16/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPNetworkManager.h"
#import "GLPWebSocketClient.h"
#import "GLPLiveConversationsManager.h"

@interface GLPNetworkManager()

@property (assign, nonatomic) GLPNetworkManagerState state;
@property (assign, nonatomic) GLPNetworkStatus networkStatus;

@end


@implementation GLPNetworkManager

@synthesize state=_state;
@synthesize networkStatus=_networkStatus;

static GLPNetworkManager *instance = nil;

+ (GLPNetworkManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPNetworkManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _state = kGLPNetworkManagerStateNeverStarted;
    _networkStatus = kGLPNetworkStatusUndefined;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
    
    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    NSLog(@"Network manager got network status update, is online: %d", isNetwork);
    
    if(isNetwork) {
        _networkStatus = kGLPNetworkStatusOnline;
        [self startNetworkOperations];
    } else {
        _networkStatus = kGLPNetworkStatusOffline;
        [self stopNetworkOperations];
    }
}

- (void)startNetworkOperations
{
    if(_state == kGLPNetworkManagerStateStarted) {
        DDLogInfo(@"Cannot start network operations, already started");
        return;
    }
    
    DDLogInfo(@"Start network operations");
    
    _state = kGLPNetworkManagerStateStarted;
    
    // start web socket, then wait for its connection before starting next requests
    [[GLPWebSocketClient sharedInstance] startWebSocket];
}

- (void)restartNetworkOperations
{
    if(_state == kGLPNetworkManagerStateNeverStarted) {
        DDLogInfo(@"Cannot restart network operations, never started");
        return;
    }
    
    [self startNetworkOperations];
}

- (void)stopNetworkOperations
{
    if(_state == kGLPNetworkManagerStateStopped) {
        DDLogInfo(@"Cannot stop network operations, already stopped");
        return;
    }
    
    _state = kGLPNetworkManagerStateStopped;
    
    [[GLPWebSocketClient sharedInstance] stopWebSocket];
    [[GLPLiveConversationsManager sharedInstance] markNotSynchronized];
}

- (void)webSocketDidConnect
{
    // init the conversations list
    [[GLPLiveConversationsManager sharedInstance] loadConversations];
}


@end
