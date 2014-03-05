//
//  GLPPushManager.h
//  Gleepost
//
//  Created by Lukas on 11/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPPushManager : NSObject

+ (GLPPushManager *)sharedInstance;
- (void)savePushToken:(NSData *)token;
- (void)registerPushTokenWithAuthParams:(NSDictionary *)authParams;
- (void)unregisterPushTokenWithAuthParams:(NSDictionary *)authParams;

@end
