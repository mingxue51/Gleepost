//
//  GLPWebSocketMessageProcessor.h
//  Gleepost
//
//  Created by Lukas on 1/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPWebSocketMessageProcessor : NSObject

+ (GLPWebSocketMessageProcessor *)sharedInstance;
- (void)processMessage:(NSString *)webSocketMessage;

@end


@interface GLPWebSocketMessageProcessorOperation : NSOperation

@property (strong, nonatomic) NSString *webSocketMessage;

@end