//
//  GLPLiveConversationsManager.m
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversationsManager.h"
#import "WebClient.h"
#import "ConversationManager.h"
#import "NSNotificationCenter+Utils.h"

@interface GLPLiveConversationsManager()

@property (strong, nonatomic) NSMutableDictionary *conversations;
@property (strong, nonatomic) NSMutableDictionary *conversationsMessages;
@property (strong, nonatomic) NSMutableDictionary *conversationsSyncStatuses;
@property (strong, nonatomic) NSMutableDictionary *conversationsMessagesKeys;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) BOOL successfullyLoaded;
@property (assign, nonatomic) BOOL isSynchronizedWithRemote;
@property (assign, nonatomic) BOOL areConversationsSync;
@property (assign, nonatomic) NSInteger liveConversationsCount;
@property (assign, nonatomic) NSInteger regularConversationsCount;

@end


@implementation GLPLiveConversationsManager

@synthesize conversations=_conversations;
@synthesize conversationsMessages=_conversationsMessages;
@synthesize conversationsMessagesKeys=_conversationsMessagesKeys;
@synthesize queue=_queue;
@synthesize successfullyLoaded=_successfullyLoaded;
@synthesize isSynchronizedWithRemote=_isSynchronizedWithRemote;
@synthesize liveConversationsCount=_liveConversationsCount;
@synthesize regularConversationsCount=_regularConversationsCount;
@synthesize areConversationsSync=_areConversationsSync;

static GLPLiveConversationsManager *instance = nil;

+ (GLPLiveConversationsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPLiveConversationsManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _conversations = [NSMutableDictionary dictionary];
    _conversationsMessages = [NSMutableDictionary dictionary];
    _conversationsMessagesKeys = [NSMutableDictionary dictionary];
    _liveConversationsCount = 0;
    _regularConversationsCount = 0;
    
    _queue = dispatch_queue_create("com.gleepost.queue.liveconversation", DISPATCH_QUEUE_SERIAL);
    _successfullyLoaded = NO;
    _isSynchronizedWithRemote = NO;
    _areConversationsSync = NO;
    
    return self;
}

//- (void)loadLocalRegularConversations
//{
//    DDLogInfo(@"Load local regular conversations");
//    
//    NSArray *conversations = [ConversationManager loadLocalRegularConversation];
//    DDLogInfo(@"Loaded %d local regular conversations", conversations.count);
//    
//    dispatch_async(_queue, ^{
//        for(GLPConversation *c in conversations) {
//            [self internalAddConversation:c];
//        }
//    });
//}

- (void)loadConversations
{
    DDLogInfo(@"Load conversations");
    
    [[WebClient sharedInstance] getConversationsWithCallback:^(BOOL success, NSArray *conversations) {
        dispatch_async(_queue, ^{
            if(!success) {
                DDLogError(@"Cannot load conversations");
                _isSynchronizedWithRemote = NO;
                return;
            }
            
            DDLogInfo(@"Load conversations sucess, loaded conversations: %d", conversations.count);
            
            for(GLPConversation *conversation in conversations) {
                [self internalAddConversation:conversation];
            }
            
            _isSynchronizedWithRemote = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
        });
    }];
}

- (void)addConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Add conversation with remote key %d", conversation.remoteKey);
    
    dispatch_async(_queue, ^{
        [self internalAddConversation:conversation];
    });
}

- (void)syncConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Sync conversation %d", conversation.remoteKey);
    
    __block NSInteger lastSyncMessageKey = NSNotFound;
    __block GLPMessage *message = nil;
    __block BOOL success = NO;
    
    dispatch_sync(_queue, ^{
        GLPConversation *syncConversation = _conversations[[NSNumber numberWithInteger:conversation.remoteKey]];
        if(!syncConversation) {
            DDLogWarn(@"Cannot sync non existent conversation");
            return;
        }
        
        // conversation has last sync message
        if(conversation.lastSyncMessageKey != NSNotFound) {
            message = [self internalFindMessageByKey:conversation.lastSyncMessageKey inConversation:conversation];
            
            if(!message) {
                DDLogWarn(@"Last sync message for key %d not found", conversation.lastSyncMessageKey);
                return;
            }
            
            lastSyncMessageKey = conversation.lastSyncMessageKey;
        }
        
        success = YES;
    });
    
    if(!success) {
        DDLogWarn(@"Sync conversation abort");
        return;
    }

    DDLogInfo(@"Last sync message: %d - %@", message.key, message.content);
    
    [[WebClient sharedInstance] getMessagesForConversation:conversation after:message before:nil callbackBlock:^(BOOL success, NSArray *messages) {
        if(!success) {
            return;
        }
        
        DDLogInfo(@"Received %d messages with success", messages.count);
        
        // reverse order
        messages = [[messages reverseObjectEnumerator] allObjects];
        
        dispatch_async(_queue, ^{
            NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
            GLPConversation *syncConversation = _conversations[index];
            if(!syncConversation) {
                DDLogWarn(@"Cannot sync non existent conversation");
                return;
            }
            
            if(syncConversation.lastSyncMessageKey != lastSyncMessageKey) {
                DDLogWarn(@"Previous last sync message key does not match the current's conversation: %d != %d", lastSyncMessageKey, syncConversation.lastSyncMessageKey);
                return;
            }
            
            [self internalInsertMessages:messages toConversation:syncConversation atTheEnd:YES];
            syncConversation.lastSyncMessageKey = [_conversationsMessagesKeys[index] integerValue];
            DDLogInfo(@"Conversation last sync message key: %d", syncConversation.lastSyncMessageKey);
            
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:Nil userInfo:@{@"remoteKey":[NSNumber numberWithInteger:syncConversation.remoteKey]}];
        });
    }];
}

- (void)markAsNotSynchronizedWithRemote
{
    dispatch_async(_queue, ^{
        _isSynchronizedWithRemote = NO;
    });
}

- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPConversation *conversation = nil;
    
    dispatch_sync(_queue, ^{
        conversation = _conversations[[NSNumber numberWithInteger:remoteKey]];
    });
    
    return conversation;
}

- (BOOL)isConversationSync:(GLPConversation *)conversation
{
    __block BOOL result;
    
    dispatch_sync(_queue, ^{
        GLPConversation *syncConversation = _conversations[[NSNumber numberWithInteger:conversation.remoteKey]];
        if(!syncConversation) {
            DDLogWarn(@"Cannot get sync status from non existent conversation");
            return;
        }
        
        result = syncConversation.isSync;
    });
    
    return result;
}

- (NSArray *)conversationsList
{
    __block NSArray *conversations;
    dispatch_sync(_queue, ^{
        conversations = [_conversations allValues];
    });
    
    return conversations;
}

- (void)conversationsList:(void (^)(NSArray *liveConversations, NSArray *regularConversations))block
{
    NSMutableArray *liveConversations = [NSMutableArray array];
    NSMutableArray *regularConversations = [NSMutableArray array];
    
    dispatch_sync(_queue, ^{
        for(GLPConversation *c in [_conversations allValues]) {
            if(c.isLive) {
                [liveConversations addObject:[c copy]];
            } else {
                [regularConversations addObject:[c copy]];
            }
        }
    });
    
    block(liveConversations, regularConversations);
}

- (NSInteger)conversationsCount
{
    __block int res = 0;
    
    dispatch_sync(_queue, ^{
        res = _conversations.count;
    });
    
    return res;
}

- (NSInteger)liveConversationsCount
{
    __block int res = 0;
    
    dispatch_sync(_queue, ^{
        res = _liveConversationsCount;
    });
    
    return res;
}

- (NSInteger)regularConversationsCount
{
    __block int res = 0;
    
    dispatch_sync(_queue, ^{
        res = _regularConversationsCount;
    });
    
    return res;
}


# pragma mark - Messages

- (NSArray *)messagesForConversation:(GLPConversation *)conversation
{
    return [self messagesForConversation:conversation startingAfter:nil];
}

- (NSArray *)messagesForConversation:(GLPConversation *)conversation startingAfter:(GLPMessage *)after
{
    DDLogInfo(@"Get messages for conversation %d, after message: %d - %@", conversation.remoteKey, after.key, after.content);
    __block NSArray *array = nil;
    
    dispatch_sync(_queue, ^{
        NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
        
        GLPConversation *synchConversation = _conversations[index];
        if(!synchConversation) {
            DDLogError(@"Cannot get messages for non existent conversation");
            return;
        }
        
        // empty messages
        if([_conversationsMessages[index] count] == 0) {
            DDLogInfo(@"No message for conversation, abort");
            return;
        }
        
        NSArray *syncMessages;
        
        if(after) {
            NSUInteger syncIndex = [self internalFindMessageIndexByKey:after.key inConversation:synchConversation];
            if(syncIndex == NSNotFound) {
                DDLogError(@"Cannot get messages after non existent message");
                return;
            }
            
//            DDLogInfo(@"Sync index %d VS count %d", syncIndex, [_conversationsMessages[index] count]);
            if(syncIndex == [_conversationsMessages[index] count] - 1) {
                DDLogInfo(@"After message is already the last one");
                return;
            }
            
            NSRange range = NSMakeRange(syncIndex + 1, [_conversationsMessages[index] count] - syncIndex);
            
            // check for out of range errors
            if(range.location + range.length > [_conversationsMessages[index] count]) {
                DDLogError(@"ERROR: Messages subarray is out of range, THIS IS WRONG!");
                return;
            }
            
            syncMessages = [_conversationsMessages[index] subarrayWithRange:range];
        } else {
            syncMessages = _conversationsMessages[index];
        }
        
        array = [[NSArray alloc] initWithArray:syncMessages copyItems:YES];
    });
    
    if(!array) {
        array = [NSArray array];
    }
    
    return array;
}

- (void)addNewMessageToConversation:(GLPMessage *)message
{
    DDLogInfo(@"Add new message \"%@\" to conversation with remote key %d", message.content, message.conversation.remoteKey);
    
    __block NSInteger key;
    
    dispatch_sync(_queue, ^{
        NSNumber *index = [NSNumber numberWithInteger:message.conversation.remoteKey];
        GLPConversation *conversation = _conversations[index];
        if(!conversation) {
            DDLogError(@"Cannot add new message to non existent conversation");
            return;
        }
        
        [conversation updateWithNewMessage:message];
        
        GLPMessage *synchMessage = [message copy];
        key = [_conversationsMessagesKeys[index] integerValue] + 1;
        synchMessage.key = key;
        
        conversation.lastSyncMessageKey = key;
        
        [_conversationsMessages[index] addObject:synchMessage];
        _conversationsMessagesKeys[index] = [NSNumber numberWithInteger:key];
    });
    
    message.key = key;
}

- (void)addMessages:(NSArray *)messages toConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Add %d messages to conversation with remote key %d", messages.count, conversation.remoteKey);
    
    dispatch_async(_queue, ^{
        GLPConversation *synchConversation = _conversations[[NSNumber numberWithInteger:conversation.remoteKey]];
        if(!synchConversation) {
            DDLogError(@"Cannot add messages to non existent conversation");
            return;
        }
        
        [self internalInsertMessages:messages toConversation:synchConversation atTheEnd:YES];
        
//        NSMutableArray *synchMessages = [NSMutableArray arrayWithCapacity:messages.count];
//        
//        NSInteger key = 1;
//        for(GLPMessage *m in messages) {
//            GLPMessage *synchMessage = [m copy];
//            synchMessage.key = key;
//            [synchMessages addObject:synchMessage];
//            key++;
//        }
//        
//        NSNumber *index = [NSNumber numberWithInteger:synchConversation.remoteKey];
//        _conversationsMessages[index] = synchMessages;
//        _conversationsMessagesKeys[index] = [NSNumber numberWithInteger:synchMessages.count];
    });
}

- (void)updateMessageAfterSending:(GLPMessage *)message
{
    DDLogInfo(@"Update message \"%@\" after sending", message.content);
    
    dispatch_async(_queue, ^{
        GLPConversation *conversation = _conversations[[NSNumber numberWithInteger:message.conversation.remoteKey]];
        if(!conversation) {
            DDLogError(@"Cannot update message for non existent conversation");
            return;
        }
        
        GLPMessage *synchMessage = [self internalFindMessageByKey:message.key inConversation:conversation];
        if(!synchMessage) {
            DDLogError(@"Cannot update non existent message");
            return;
        }
        
        synchMessage.sendStatus = message.sendStatus;
        if(message.sendStatus == kSendStatusSent) {
            synchMessage.remoteKey = message.remoteKey;
        }
    });
}

- (void)addMessages:(NSArray *)messages toConversation:(GLPConversation *)conversation before:(GLPMessage *)message
{
    DDLogInfo(@"Add messages to live conversation before %@", message.content);
    
    dispatch_async(_queue, ^{
        GLPConversation *syncConversation = _conversations[[NSNumber numberWithInteger:conversation.remoteKey]];
        if(!syncConversation) {
            DDLogError(@"Cannot add messages for non existent conversation");
            return;
        }
        
        NSNumber *index = [NSNumber numberWithInteger:syncConversation.remoteKey];
        
        if(message) {
            // check that the before message is the last one
            GLPMessage *last = [_conversationsMessages[index] firstObject];
            if(last.remoteKey != message.remoteKey) {
                DDLogWarn(@"The last message (%d - %@) is not equal to the before message (%d)", last.remoteKey, last.content, message.remoteKey);
                return;
            }
        } else {
            // or check that there is no messages
            NSInteger count = [_conversationsMessages[index] count];
            if(count != 0) {
                DDLogWarn(@"The before message is nil, but the live conversation messages list is not empty (count=%d)", count);
                return;
            }
        }
        
        [self internalInsertMessages:messages toConversation:syncConversation atTheEnd:NO];
    });
}


# pragma mark - Internal

// Internal
// Should be called inside a queue block
//- (GLPConversation *)internalFindConversationByRemoteKey:(NSInteger)remoteKey
//{
//    NSUInteger index = [_conversations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        if(((GLPConversation *)obj).remoteKey == remoteKey) {
//            *stop = YES;
//            return YES;
//        }
//        
//        return NO;
//    }];
//    
//    if(index == NSNotFound) {
//        DDLogError(@"Live conversation not found for remote key %d", remoteKey);
//        return nil;
//    }
//    
//    return _conversations[index];
//}

// Internal
// Should be called inside a queue block
- (GLPMessage *)internalFindMessageByKey:(NSInteger)key inConversation:(GLPConversation *)conversation
{
    NSUInteger index = [self internalFindMessageIndexByKey:key inConversation:conversation];
    
    if(index == NSNotFound) {
        DDLogError(@"Live conversation's message not found for key %d", key);
        return nil;
    }
    
    return _conversationsMessages[[NSNumber numberWithInteger:conversation.remoteKey]][index];
}

// Internal
// Should be called inside a queue block
- (NSUInteger)internalFindMessageIndexByKey:(NSInteger)key inConversation:(GLPConversation *)conversation
{
    NSArray *messages = _conversationsMessages[[NSNumber numberWithInteger:conversation.remoteKey]];
    NSUInteger index = [messages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if(((GLPMessage *)obj).key == key) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    return index;
}

// Internal
// Should be called inside a queue block
- (void)internalInsertMessages:(NSArray *)messages toConversation:(GLPConversation *)conversation atTheEnd:(BOOL)end
{
    NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
    NSMutableArray *synchMessages = [NSMutableArray arrayWithCapacity:messages.count];
    
    NSInteger key = [_conversationsMessagesKeys[index] integerValue];
    for(GLPMessage *m in messages) {
        key++;
        
        GLPMessage *synchMessage = [m copy];
        synchMessage.key = key;
        [synchMessages addObject:synchMessage];
    }
    
    // insert messages at the end or if the array is empty
    if(end || [_conversationsMessages[index] count] == 0) {
        [_conversationsMessages[index] addObjectsFromArray:synchMessages];
    } else {
        [_conversationsMessages[index] insertObjects:synchMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, synchMessages.count)]];
    }
    
    _conversationsMessagesKeys[index] = [NSNumber numberWithInteger:key];
}



// Internal
// Should be called inside a queue block
- (void)internalAddConversation:(GLPConversation *)conversation
{
    NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
    
    // do not add twice the same conversation
    if(_conversations[index]) {
        DDLogWarn(@"Conversation already exists, cannot add twice");
        
        // copy only last message and date, it may have changed (?)
        GLPConversation *existingC = _conversations[index];
        existingC.lastMessage = conversation.lastMessage;
        existingC.lastUpdate = conversation.lastUpdate;
        return;
    }
    
    conversation.isSync = NO;
    
    if(conversation.isLive) {
        _conversationsMessages[index] = [NSMutableArray array];
        _conversationsMessagesKeys[index] = [NSNumber numberWithInteger:0];
        _liveConversationsCount++;
    } else {
        _regularConversationsCount++;
    }
    
    _conversations[index] = conversation;
}

@end
