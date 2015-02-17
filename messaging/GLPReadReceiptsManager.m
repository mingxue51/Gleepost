//
//  GLPReadReceiptsManager.m
//  Gleepost
//
//  Created by Silouanos on 17/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class manages all the read receipts operations and keeps all the read receipts date structures.

#import "GLPReadReceiptsManager.h"
#import "GLPReadReceipt.h"
#import "GLPWebSocketEvent.h"
#import "GLPMessage.h"
#import "SessionManager.h"
#import "NSNotificationCenter+Utils.h"

@interface GLPReadReceiptsManager ()

/** Will have the following format <ConversationRemoteKey, GLPReadReceipt>. */
@property (strong, nonatomic) NSMutableDictionary *readReceipts;

@end

@implementation GLPReadReceiptsManager

static GLPReadReceiptsManager *instance = nil;

+ (GLPReadReceiptsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPReadReceiptsManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _readReceipts = [[NSMutableDictionary alloc] init];
    }

    return self;
}

#pragma mark - Modifiers

//TODO: What happens when we add a message as read receipt in the same conversation?
//Answer: Remove the entry once user presses the send button.

- (void)addReadReceiptWithWebSocketEvent:(GLPWebSocketEvent *)webSocketEvent
{
    if([webSocketEvent.data[@"last_read"] integerValue] == 0 || [webSocketEvent.data[@"user"] integerValue] == [SessionManager sharedInstance].user.remoteKey)
    {
        return;
    }
    
    GLPReadReceipt *readReceipt = [[GLPReadReceipt alloc] initWithWebSocketEvent:webSocketEvent];

    GLPReadReceipt *existedReadReceipt = [_readReceipts objectForKey: @([readReceipt getConversationRemoteKey])];
    
    if(existedReadReceipt)
    {
        [existedReadReceipt addUserWithUser: [readReceipt getLastUser]];
    }
    else
    {
        [_readReceipts setObject:readReceipt forKey:@([readReceipt getConversationRemoteKey])];
    }
    
    DDLogDebug(@"GLPReadReceiptsManager : received read %@", [readReceipt getLastUser]);
    
    //TODO: Send NSNotification to GLPConversationViewController and then refresh the cell.
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:GLPNOTIFICATION_READ_RECEIPT_RECEIVED object:self userInfo:@{}];
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_READ_RECEIPT_RECEIVED object:self];
}

/**
 Once user sends a message, this method should be called.
 
 @param conversationRemoteKey conversation's remote key.
 
 */
- (void)removeReadReceiptWithConversationRemoteKey:(NSInteger)conversationRemoteKey
{
    [_readReceipts removeObjectForKey:@(conversationRemoteKey)];
}

#pragma mark - Accessors

- (NSString *)getReadReceiptMessageWithMessage:(GLPMessage *)message
{
    GLPReadReceipt *readReceipt = [_readReceipts objectForKey:@(message.conversation.remoteKey)];

    if([self doesMessageNeedSeenMessage:message])
    {
        return [readReceipt generateSeenMessage];
    }
    
    return nil;
}

- (BOOL)doesMessageNeedSeenMessage:(GLPMessage *)message
{
    GLPReadReceipt *readReceipt = [_readReceipts objectForKey:@(message.conversation.remoteKey)];
    
    if([readReceipt getMesssageRemoteKey] == message.remoteKey)
    {
        return YES;
    }
    
    return NO;
}

@end
