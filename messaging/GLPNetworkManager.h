//
//  GLPNetworkManager.h
//  Gleepost
//
//  Created by Lukas on 1/16/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPNetworkManager : NSObject

typedef enum {
    kGLPNetworkManagerStateStarted,
    kGLPNetworkManagerStateStopped
} GLPNetworkManagerState;

+ (GLPNetworkManager *)sharedInstance;
- (void)startNetworkOperations;
- (void)stopNetworkOperations;

@end
