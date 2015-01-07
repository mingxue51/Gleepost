//
//  GLPWebSocketClient.h
//  Gleepost
//
//  Created by Lukas on 1/21/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@interface GLPWebSocketClient : NSObject <SRWebSocketDelegate>

+ (GLPWebSocketClient *)sharedInstance;
- (void)startWebSocket;
- (void)stopWebSocket;
- (void)sendMessageWithJson:(NSData *)data;

@end
