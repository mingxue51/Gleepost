//
//  GLPWebSocketEvent.h
//  Gleepost
//
//  Created by Lukas on 1/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLPWebSocketEvent : NSObject

typedef enum {
    kGLPWebSocketEventTypeNewMessage,
    kGLPWebSocketEventTypeNewConversation,
    kGLPWebSocketEventTypeEndConversation,
    kGLPWebSocketEventTypeChangedConversation,
    kGLPWebSocketEventTypeNotification,
    kGLPWebSocketEventTypeVideoReady,
    kGLPWebSocketEventTypeRead,
    kGLPWebSocketEventTypeViews,
    kGLPWebSocketEventTypeVote,
    kGLPWebSocketEventTypePresence
} GLPWebSocketEventType;

@property (assign, nonatomic) GLPWebSocketEventType type;
@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSString *location;

- (void)typeFromString:(NSString *)string;
- (NSInteger)webSocketMessageRemoteKeyFromLocation;

@end
