//
//  GLPReadReceiptsManager.h
//  Gleepost
//
//  Created by Silouanos on 17/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPWebSocketEvent;
@class GLPMessage;

@interface GLPReadReceiptsManager : NSObject

+ (GLPReadReceiptsManager *)sharedInstance;
- (void)addReadReceiptWithWebSocketEvent:(GLPWebSocketEvent *)webSocketEvent;
- (void)removeReadReceiptWithConversationRemoteKey:(NSInteger)conversationRemoteKey;
- (NSString *)getReadReceiptMessageWithMessage:(GLPMessage *)message;
- (BOOL)doesMessageNeedSeenMessage:(GLPMessage *)message;

@end
