//
//  GLPWebSocketMessageProcessor.h
//  Gleepost
//
//  Created by Lukas on 1/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPMessage.h"

@interface GLPMessageProcessor : NSObject

+ (GLPMessageProcessor *)sharedInstance;
- (void)processWebSocketMessage:(NSString *)webSocketMessage;
- (void)processLocalMessage:(GLPMessage *)message;

@end