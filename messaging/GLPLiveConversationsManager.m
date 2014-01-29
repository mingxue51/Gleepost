//
//  GLPLiveConversationsManager.m
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "GLPLiveConversationsManager.h"
//#import "NSMutableArray+QueueAdditions.h"
#import "WebClient.h"

@interface GLPLiveConversationsManager()

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) NSMutableDictionary *conversationsMessages;
@property (strong, nonatomic) NSMutableDictionary *conversationsMessagesKeys;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) BOOL successfullyLoaded;
@property (assign, nonatomic) BOOL isSynchronizedWithRemote;

@end


@implementation GLPLiveConversationsManager

@synthesize conversations=_conversations;
@synthesize conversationsMessages=_conversationsMessages;
@synthesize conversationsMessagesKeys=_conversationsMessagesKeys;
@synthesize queue=_queue;
@synthesize successfullyLoaded=_successfullyLoaded;
@synthesize isSynchronizedWithRemote=_isSynchronizedWithRemote;

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
    
    _conversations = [NSMutableArray array];
    _conversationsMessages = [NSMutableDictionary dictionary];
    _conversationsMessagesKeys = [NSMutableDictionary dictionary];
    _queue = dispatch_queue_create("com.gleepost.queue.liveconversation", DISPATCH_QUEUE_SERIAL);
    _successfullyLoaded = NO;
    _isSynchronizedWithRemote = NO;
    
    return self;
}

- (void)loadConversations
{
    DDLogInfo(@"Load live conversations");
    
    [[WebClient sharedInstance] getLiveConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
        dispatch_async(_queue, ^{
            if(!success) {
                DDLogError(@"Cannot load live conversations");
                _isSynchronizedWithRemote = NO;
                return;
            }
            
            DDLogInfo(@"Load live conversations sucess, loaded conversations: %d", conversations.count);
            
            _conversations = [NSMutableArray arrayWithArray:conversations];
            _conversationsMessages = [NSMutableDictionary dictionary]; // reset if need
            _conversationsMessagesKeys = [NSMutableDictionary dictionary]; // reset if need
            
            for(GLPConversation *c in _conversations) {
                c.isSync = NO;
                
                NSNumber *index = [NSNumber numberWithInteger:c.remoteKey];
                _conversationsMessages[index] = [NSMutableArray array];
                _conversationsMessagesKeys[index] = [NSNumber numberWithInteger:0];
            }
            
            _isSynchronizedWithRemote = YES;
        });
    }];
}

- (void)syncConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Sync conversation %d", conversation.remoteKey);
    
    __block NSInteger lastSyncMessageKey = NSNotFound;
    __block GLPMessage *message = nil;
    __block BOOL success = NO;
    
    dispatch_sync(_queue, ^{
        GLPConversation *syncConversation = [self internalFindConversationByRemoteKey:conversation.remoteKey];
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
        
        dispatch_async(_queue, ^{
            GLPConversation *syncConversation = [self internalFindConversationByRemoteKey:conversation.remoteKey];
            if(!syncConversation) {
                DDLogWarn(@"Cannot sync non existent conversation");
                return;
            }
            
            if(syncConversation.lastSyncMessageKey != lastSyncMessageKey) {
                DDLogWarn(@"Previous last sync message key does not match the current's conversation: %d != %d", lastSyncMessageKey, syncConversation.lastSyncMessageKey);
                return;
            }
            
            
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
        conversation = [self internalFindConversationByRemoteKey:remoteKey];
    });
    
    return conversation;
}

- (NSArray *)conversations
{
    __block NSArray *conversations;
    dispatch_sync(_queue, ^{
        conversations = [_conversations copy];
    });
    
    return conversations;
}

- (int)conversationsCount
{
    __block int res = 0;
    
    dispatch_sync(_queue, ^{
        res = _conversations.count;
    });
    
    return res;
}


# pragma mark - Messages

- (NSArray *)messagesForConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Get messages for live conversation %d", conversation.remoteKey);
    __block NSArray *array = nil;
    
    dispatch_sync(_queue, ^{
        GLPConversation *synchConversation = [self internalFindConversationByRemoteKey:conversation.remoteKey];
        if(!synchConversation) {
            DDLogError(@"Cannot get messages for non existent conversation");
            return;
        }
        
        NSNumber *index = [NSNumber numberWithInteger:synchConversation.remoteKey];
        array = [[NSArray alloc] initWithArray:_conversationsMessages[index] copyItems:YES];
    });
    
    if(!array) {
        array = [NSArray array];
    }
    
    return array;
}

- (void)addNewMessageToConversation:(GLPMessage *)message
{
    DDLogInfo(@"Add new message %@ to live conversation with remote key %d", message.content, message.conversation.remoteKey);
    
    __block NSInteger key;
    
    dispatch_sync(_queue, ^{
        GLPConversation *conversation = [self internalFindConversationByRemoteKey:message.conversation.remoteKey];
        if(!conversation) {
            DDLogError(@"Cannot add new message to non existent conversation");
            return;
        }
        
        [conversation updateWithNewMessage:message];
        
        NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
        NSMutableArray *messages = _conversationsMessages[index];
        
        GLPMessage *synchMessage = [message copy];
        key = [_conversationsMessagesKeys[index] integerValue] + 1;
        synchMessage.key = key;
        [messages addObject:synchMessage];
        _conversationsMessagesKeys[index] = [NSNumber numberWithInteger:key];
    });
    
    message.key = key;
}

- (void)addMessages:(NSArray *)messages toConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Add %d messages to conversation with remote key %d", messages.count, conversation.remoteKey);
    
    dispatch_async(_queue, ^{
        GLPConversation *synchConversation = [self internalFindConversationByRemoteKey:conversation.remoteKey];
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
        GLPConversation *conversation = [self internalFindConversationByRemoteKey:message.conversation.remoteKey];
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
        GLPConversation *syncConversation = [self internalFindConversationByRemoteKey:conversation.remoteKey];
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
- (GLPConversation *)internalFindConversationByRemoteKey:(NSInteger)remoteKey
{
    NSUInteger index = [_conversations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if(((GLPConversation *)obj).remoteKey == remoteKey) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    if(index == NSNotFound) {
        DDLogError(@"Live conversation not found for remote key %d", remoteKey);
        return nil;
    }
    
    return _conversations[index];
}

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

@end
