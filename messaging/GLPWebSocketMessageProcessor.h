//
//  GLPWebSocketMessageProcessor.h
//  Gleepost
//
//  Created by Lukas on 1/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPMessage.h"

@interface GLPWebSocketMessageProcessor : NSObject

+ (GLPWebSocketMessageProcessor *)sharedInstance;
- (void)processMessage:(NSString *)webSocketMessage;

@end


@interface GLPNewMessageProcessorOperation : NSOperation

@property (strong, nonatomic) GLPMessage *message;

@end


@interface GLPWebSocketMessageProcessorOperation : NSOperation

@property (strong, nonatomic) NSString *webSocketMessage;

@end