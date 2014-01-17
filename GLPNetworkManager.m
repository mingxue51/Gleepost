//
//  GLPNetworkManager.m
//  Gleepost
//
//  Created by Lukas on 1/16/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPNetworkManager.h"

@interface GLPNetworkManager()

@property (assign, nonatomic) GLPNetworkManagerState state;

@end


@implementation GLPNetworkManager

@synthesize state=_state;

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
    
    _state = kGLPNetworkManagerStateStopped;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:@"GLPNetworkStatusUpdate" object:nil];
    
    return self;
}

- (void)updateNetworkStatus:(NSNotification *)notification
{
    BOOL isNetwork = [notification.userInfo[@"status"] boolValue];
    NSLog(@"Network manager got network status update, is online: %d", isNetwork);
    
    if(isNetwork) {
        [self startNetworkOperations];
    } else {
        [self stopNetworkOperations];
    }
}

- (void)startNetworkOperations
{
    if(_state == kGLPNetworkManagerStateStarted) {
        DDLogInfo(@"Cannot start network operations, already started");
        return;
    }
    
    _state = kGLPNetworkManagerStateStarted;
}

- (void)stopNetworkOperations
{
    if(_state == kGLPNetworkManagerStateStopped) {
        DDLogInfo(@"Cannot stop network operations, already stopped");
        return;
    }
    
    _state = kGLPNetworkManagerStateStopped;
}


@end
