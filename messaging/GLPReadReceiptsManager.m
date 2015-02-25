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
#import "GLPLiveConversationsManager.h"
#import "GLPLiveGroupConversationsManager.h"
#import "GLPConversationRead.h"
#import "ConversationManager.h"

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

//What happens when we add a message as read receipt in the same conversation?
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
    
    [self updateConversationReadsWithReadReceipt:readReceipt];

    
    DDLogDebug(@"GLPReadReceiptsManager : received read %@ data structure %@", [readReceipt getLastUser], _readReceipts);
    
    //Send NSNotification to GLPConversationViewController and then refresh the cell.

    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_READ_RECEIPT_RECEIVED object:self userInfo:@{@"message_remote_key" : @([readReceipt getMesssageRemoteKey])}];
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

- (NSArray *)usersWithMessage:(GLPMessage *)message
{
    GLPReadReceipt *readReceipt = [_readReceipts objectForKey:@(message.conversation.remoteKey)];
    
    if([self doesMessageNeedSeenMessage:message])
    {
        return [readReceipt users];
    }
    
    return nil;
}

- (BOOL)doesMessageNeedSeenMessage:(GLPMessage *)message
{
    GLPReadReceipt *readReceipt = [_readReceipts objectForKey:@(message.conversation.remoteKey)];
    
    if(!readReceipt)
    {
        return NO;
    }
    
    if([readReceipt getMesssageRemoteKey] == message.remoteKey && message.author.remoteKey != [readReceipt getLastUser].remoteKey)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - Updates

/**
 Updates or add the conversation reads array (in conversation instances - either GLPLiveGroupConversationsManager
 or GLPLiveConversationsManager) and in local database in conversation_reads.
 
 @param readReceipt the new read receipt that just received from web socket.
 
 */
- (void)updateConversationReadsWithReadReceipt:(GLPReadReceipt *)readReceipt
{
    [self updateConversationWithReadReceipt:readReceipt];
    
    [self updateDatabaseConversationWithReadReceipt:readReceipt];
}

- (void)updateDatabaseConversationWithReadReceipt:(GLPReadReceipt *)readReceipt
{
    [ConversationManager saveOrUpdateReadWithReadReceipt:readReceipt];
}

- (void)updateConversationWithReadReceipt:(GLPReadReceipt *)readReceipt
{
    GLPConversation *conversation = [self getConversationWithReadReceipt:readReceipt];
    
    if(conversation)
    {
        NSArray *reads = conversation.reads;
        
        for(GLPConversationRead *convRead in reads)
        {
            if(convRead.participant.remoteKey == [readReceipt getLastUser].remoteKey)
            {
                DDLogInfo(@"GLPReadReceiptsManager : read updated %@", conversation.title);
                convRead.messageRemoteKey = [readReceipt getMesssageRemoteKey];
                return;
            }
        }
        
        NSMutableArray *updatedReads = reads.mutableCopy;
        [updatedReads addObject:[[GLPConversationRead alloc] initWithParticipant:[readReceipt getLastUser] andMessageRemoteKey:[readReceipt getMesssageRemoteKey]]];
        reads = updatedReads;
        
        DDLogInfo(@"GLPReadReceiptsManager : read added %@ updated reads: %@", conversation.title, reads);
    }
}

/**
 Finds where the message belongs to
 */

- (GLPConversation *)getConversationWithReadReceipt:(GLPReadReceipt *)readReceipt
{
    GLPConversation *conversation = nil;
    
    conversation = [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:[readReceipt getConversationRemoteKey]];
    
    if(conversation)
    {
        DDLogDebug(@"GLPReadReceiptsManager : conversation found %@", conversation.reads);
        
        return conversation;
    }
    
    conversation = [[GLPLiveGroupConversationsManager sharedInstance] findByRemoteKey:[readReceipt getConversationRemoteKey]];
    return conversation;
}

@end
