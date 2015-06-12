//
//  GLPWebSocketMessageProcessor.m
//  Gleepost
//
//  Created by Lukas on 1/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "GLPMessageProcessor.h"
#import "RemoteParser.h"
#import "ConversationManager.h"
#import "GLPLiveConversationsManager.h"
#import "GLPNotificationManager.h"
#import "GLPWebSocketEvent.h"
#import "Conversation.h"
#import "GLPNotification.h"
#import "NSNotificationCenter+Utils.h"
#import "WebClient.h"
#import "GLPVideoUploadManager.h"
#import "GLPTrackViewsCountProcessor.h"
#import "GLPLiveGroupConversationsManager.h"
#import "UserManager.h"
#import "GLPReadReceiptsManager.h"
#import "GLPPollOperationManager.h"

@interface GLPMessageProcessor()

@property (strong, nonatomic) dispatch_queue_t queue;

@end

@implementation GLPMessageProcessor

@synthesize queue=_queue;

static GLPMessageProcessor *instance = nil;

+ (GLPMessageProcessor *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPMessageProcessor alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _queue = dispatch_queue_create("com.gleepost.queue.messageprocessor", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

- (void)processLocalMessage:(GLPMessage *)message
{
    dispatch_async(_queue, ^{
        [ConversationManager sendMessage:message];
    });
}

- (void)processWebSocketMessage:(NSString *)webSocketMessage
{
    dispatch_async(_queue, ^{
        if([webSocketMessage caseInsensitiveCompare:@"Invalid credentials"] == NSOrderedSame) {
            DDLogError(@"Web socket connection closed because of invalid credentials");
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[webSocketMessage dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

        GLPWebSocketEvent *event = [RemoteParser parseWebSocketEventFromJson:json];
        
        if(!event)
        {
            return;
        }
        
        switch (event.type) {
            case kGLPWebSocketEventTypeNewMessage: {
                DDLogInfo(@"Websocket event: New message");
                DDLogDebug(@"Websocket event json %@", json);
                GLPMessage *message = [RemoteParser parseMessageFromJson:event.data forConversation:nil];
                
                if(message.belongsToGroup)
                {
                    [[GLPLiveGroupConversationsManager sharedInstance] addRemoteMessage:message toConversationWithRemoteKey:[event webSocketMessageRemoteKeyFromLocation]];
                }
                else
                {
                    [[GLPLiveConversationsManager sharedInstance] addRemoteMessage:message toConversationWithRemoteKey:[event webSocketMessageRemoteKeyFromLocation]];
                }
                
                break;
            }
                
            case kGLPWebSocketEventTypeNewConversation: {
                DDLogInfo(@"Websocket event: New conversation");
                GLPConversation *conversation = [RemoteParser parseConversationFromJson:event.data];
                [[GLPLiveConversationsManager sharedInstance] addConversation:conversation];
                break;
            }
                
            case kGLPWebSocketEventTypeEndConversation: {
                DDLogInfo(@"Websocket event: End conversation");
                GLPConversation *conversation = [RemoteParser parseConversationFromJson:event.data];
                [[GLPLiveConversationsManager sharedInstance] endConversation:conversation];
                break;
            }
                
            case kGLPWebSocketEventTypeChangedConversation: {
                DDLogInfo(@"Websocket event: Changed conversation");
                GLPConversation *conversation = [RemoteParser parseConversationFromJson:event.data];
                [[GLPLiveConversationsManager sharedInstance] randomToRegular:conversation];
                break;
            }
                
            case kGLPWebSocketEventTypeNotification:{
                GLPNotification *notification = [RemoteParser parseNotificationFromJson:event.data];
                [GLPNotificationManager saveNotification:notification];
                break;
            }
                
            case kGLPWebSocketEventTypeVideoReady:{
                [[GLPVideoUploadManager sharedInstance] refreshVideoPostInCampusWallWithData:event.data];
                break;
            }
                
            case kGLPWebSocketEventTypeViews: {
                [GLPTrackViewsCountProcessor updateViewsCounter:[event.data[@"views"] integerValue] onPost:[event.data[@"post"] integerValue]];
                break;
            }
            case kGLPWebSocketEventTypeRead: {
                GLPUser *user = [UserManager getUserForRemoteKey:[event.data[@"user"] integerValue]];
                [[GLPReadReceiptsManager sharedInstance] addReadReceiptWithWebSocketEvent:event];
                DDLogDebug(@"WebSocket event read %@ - %@", event.data[@"last_read"], user);
                break;
            }
            case kGLPWebSocketEventTypeVote: {
                
                //Update data structure, local database and UI if needed.
                [[GLPPollOperationManager sharedInstance] updatePollPostWithRemoteKey:[event webSocketMessageRemoteKeyFromLocation] withData:[RemoteParser parsePollDataWithPollData:event.data]];
                DDLogDebug(@"WebSocket event: event type vote received %@",event.data);
                break;
            }
           
            default:
                //DDLogInfo(@"Websocket event: Not recognised");
                break;
        }
    });
}

@end