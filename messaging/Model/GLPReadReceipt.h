//
//  GLPReadReceipt.h
//  Gleepost
//
//  Created by Silouanos on 17/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPUser;
@class GLPWebSocketEvent;

@interface GLPReadReceipt : NSObject

- (id)initWithWebSocketEvent:(GLPWebSocketEvent *)webSocketEvent;
- (void)addUserWithUser:(GLPUser *)user;
- (GLPUser *)getLastUser;
- (NSInteger)getConversationRemoteKey;
- (NSInteger)getMesssageRemoteKey;
- (NSString *)generateSeenMessage;

@end
