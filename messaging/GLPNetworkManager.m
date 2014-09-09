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

#import "GLPNotificationManager.h"
#import "NSNotificationCenter+Utils.h"
#import "WebClient.h"
#import "GLPLiveGroupManager.h"
#import "GLPProfileLoader.h"

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
    
    //That it seems that is not working anymore.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:GLPNOTIFICATION_NETWORK_UPDATE object:nil];
    
    [self loadAppsData];
    
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
    
    DDLogInfo(@"Restart network operations");
    
    [self startNetworkOperations];
}

- (void)stopNetworkOperations
{
    if(_state == kGLPNetworkManagerStateStopped) {
        DDLogInfo(@"Cannot stop network operations, already stopped");
        return;
    }
    
    DDLogInfo(@"Stop network operations");
    
    _state = kGLPNetworkManagerStateStopped;
    
    [[GLPWebSocketClient sharedInstance] stopWebSocket];
    [[GLPLiveConversationsManager sharedInstance] markNotSynchronized];
}

- (void)webSocketDidConnect
{
    // init the conversations list.
    [[GLPLiveConversationsManager sharedInstance] loadConversations];
    
    // init the groups list.
    [[GLPLiveGroupManager sharedInstance] loadGroups];
    
    // load user's data.
 //   [[GLPProfileLoader sharedInstance] loadUserData];

    
    // get notifications
    __block BOOL requestsSuccess = YES;
    __block int conversationsNumber = 0;
    
    UIApplication *application = [UIApplication sharedApplication];
    if(application.applicationIconBadgeNumber > 0)
    {
        [GLPNotificationManager fetchNotificationsFromServerWithCallBack:^(BOOL success, NSArray *notifications) {
            
            if(success)
            {
                //Check for new notifications.
                int notificationsNumber = notifications.count;
                
                //Subtract the number of application badge number with number of notifications.
                conversationsNumber = application.applicationIconBadgeNumber - notificationsNumber;
                
                
                NSDictionary *args = @{@"conversationsCount":[NSNumber numberWithInt:conversationsNumber]};
                
                //Set the number of conversations in tab bar.
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CONVERSATION_COUNT object:nil userInfo:args];
                
            }
        }];
    }
    
    [[WebClient sharedInstance] markConversationsRead:^(BOOL success) {
        requestsSuccess = success;
    }];
    
    if(requestsSuccess) {
        application.applicationIconBadgeNumber = 0;
        DDLogInfo(@"Reset application icon badge number to 0");
    }
}

- (void)webSocketDidFailOrClose
{
    [self stopNetworkOperations];
}


/**
 This method should be called even the app don't know if there is network
 or not. So it's called anyway.
 */
- (void)loadAppsData
{
    // load user's data even if there is no network.
    [[GLPProfileLoader sharedInstance] loadUserData];
}


@end
