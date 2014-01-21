//
//  GLPNetworkManager.h
//  Gleepost
//
//  Created by Lukas on 1/16/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kGLPNetworkManagerStateStarted,
    kGLPNetworkManagerStateStopped,
    kGLPNetworkManagerStateNeverStarted
} GLPNetworkManagerState;

typedef enum {
    kGLPNetworkStatusOnline,
    kGLPNetworkStatusOffline,
    kGLPNetworkStatusUndefined
} GLPNetworkStatus;


@interface GLPNetworkManager : NSObject

@property (assign, nonatomic, readonly) GLPNetworkStatus networkStatus;

+ (GLPNetworkManager *)sharedInstance;
- (void)startNetworkOperations;
- (void)restartNetworkOperations;
- (void)stopNetworkOperations;
- (void)webSocketDidConnect;

@end
