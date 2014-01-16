//
//  GLPWebSocketMessageProcessor.m
//  Gleepost
//
//  Created by Lukas on 1/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPWebSocketMessageProcessor.h"
#import "RemoteParser.h"
#import "ConversationManager.h"
#import "GLPNotificationManager.h"
#import "GLPWebSocketEvent.h"
#import "Conversation.h"
#import "GLPNotification.h"
#import "NSNotificationCenter+Utils.h"


@interface GLPWebSocketMessageProcessor()

@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation GLPWebSocketMessageProcessor

@synthesize queue=_queue;

static GLPWebSocketMessageProcessor *instance = nil;

+ (GLPWebSocketMessageProcessor *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPWebSocketMessageProcessor alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _queue = [[NSOperationQueue alloc] init];
    [_queue setMaxConcurrentOperationCount:1]; // process messages in sequential order
    
    return self;
}

- (void)processNewMessage:(GLPMessage *)message
{
    GLPNewMessageProcessorOperation *operation = [[GLPNewMessageProcessorOperation alloc] init];
    operation.message = message;
    
    [_queue addOperation:operation];
}

- (void)processMessage:(NSString *)webSocketMessage
{
    GLPWebSocketMessageProcessorOperation *operation = [[GLPWebSocketMessageProcessorOperation alloc] init];
    operation.webSocketMessage = webSocketMessage;
    
    [_queue addOperation:operation];
}

@end


@implementation GLPNewMessageProcessorOperation

@synthesize message=_message;

- (void)main {
    @autoreleasepool {
        
    }
}

@end


@implementation GLPWebSocketMessageProcessorOperation

@synthesize webSocketMessage=_webSocketMessage;

- (void)main {
    @autoreleasepool {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[_webSocketMessage dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        GLPWebSocketEvent *event = [RemoteParser parseWebSocketEventFromJson:json];
        
        switch (event.type) {
            case kGLPWebSocketEventTypeNewMessage: {
                GLPMessage *message = [RemoteParser parseMessageFromJson:event.data forConversation:nil];
                [ConversationManager saveMessage:message forConversationRemoteKey:[event conversationRemoteKeyFromLocation]];
                break;
            }
                
            case kGLPWebSocketEventTypeNewConversation: {
                GLPConversation *conversation = [RemoteParser parseConversationFromJson:event.data];
                [ConversationManager saveConversation:conversation];
                break;
            }
                
            case kGLPWebSocketEventTypeEndConversation: {
                
                break;
            }
                
            case kGLPWebSocketEventTypeNotification:{
                GLPNotification *notification = [RemoteParser parseNotificationFromJson:event.data];
                [GLPNotificationManager saveNotification:notification];
                break;
            }
        }

    }
}

@end