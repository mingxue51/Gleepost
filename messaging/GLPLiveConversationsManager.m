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
#import "NSMutableArray+QueueAdditions.h"
#import "SessionManager.h"

@interface GLPLiveConversationsManager()

@property (strong, nonatomic) NSMutableDictionary *conversations;
@property (strong, nonatomic) NSMutableDictionary *conversationsMessages;
@property (strong, nonatomic) NSMutableDictionary *conversationsSyncStatuses;
@property (strong, nonatomic) NSMutableDictionary *conversationsMessagesKeys;
@property (strong, nonatomic) NSMutableDictionary *conversationsLastestMessageShown;
@property (strong, nonatomic) NSMutableDictionary *conversationsOldestMessageShown;
@property (strong, nonatomic) NSMutableDictionary *conversationsCanHavePreviousMessages;
@property (strong, nonatomic) NSMutableArray *liveConversationsEndedOrder;
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
@synthesize conversationsSyncStatuses=_conversationsSyncStatuses;
@synthesize conversationsMessagesKeys=_conversationsMessagesKeys;
@synthesize conversationsLastestMessageShown=_conversationsLastestMessageShown;
@synthesize conversationsOldestMessageShown=_conversationsOldestMessageShown;
@synthesize conversationsCanHavePreviousMessages=_conversationsCanHavePreviousMessages;
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
    
    [self internalConfigureInitialState];
    _queue = dispatch_queue_create("com.gleepost.queue.liveconversation", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

- (void)clear
{
    dispatch_async(_queue, ^{
        [self internalConfigureInitialState];
    });
}

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
                [self internalAddConversation:conversation isEmpty:NO];
            }
            
            _isSynchronizedWithRemote = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_SYNCHRONIZED_WITH_REMOTE object:nil];
        });
    }];
}

- (void)createRandomConversation:(void (^)(GLPConversation *conversation))callback
{
    DDLogInfo(@"Create random conversation");
    
    dispatch_async(_queue, ^{
        GLPConversation *conversation = [[WebClient sharedInstance] synchronousCreateConversationWithUser:nil];
        if(!conversation) {
            DDLogWarn(@"Cannot create new random conversation in server, abort");
            return;
        }
        
        BOOL success = [self internalAddConversation:conversation isEmpty:YES];
        DDLogInfo(@"Conversation created succesfully: %d", success);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(success) {
                callback(conversation);
            } else {
                callback(nil);
            }
        });
    });
}

- (void)createRegularConversationWithUser:(GLPUser *)user callback:(void (^)(GLPConversation *conversation))callback
{
    DDLogInfo(@"Create regular conversation with user %d - %@", user.remoteKey, user.name);
    
    dispatch_async(_queue, ^{
        GLPConversation *conversation = [[WebClient sharedInstance] synchronousCreateConversationWithUser:user];
        if(!conversation) {
            DDLogWarn(@"Cannot create new regular conversation in server, abort");
            return;
        }
        
        BOOL success = [self internalAddConversation:conversation isEmpty:YES];
        DDLogInfo(@"Conversation created succesfully: %d", success);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(success) {
                callback(conversation);
            } else {
                callback(nil);
            }
        });
    });
}

- (void)addConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Add conversation with remote key %d", conversation.remoteKey);
    
    if(conversation.remoteKey == 0) {
        DDLogError(@"Cannot add conversation with no remote key, abort");
        return;
    }
    
    dispatch_async(_queue, ^{
        // checks for existing conversation inside
        BOOL success = [self internalAddConversation:conversation isEmpty:YES];
        if(!success) {
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    });
}

- (void)endConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"End conversation with remote key %d", conversation.remoteKey);
    
    if(conversation.remoteKey == 0) {
        DDLogError(@"Cannot end conversation with no remote key, abort");
        return;
    }
    
    dispatch_async(_queue, ^{
        NSNumber *remoteKey = [conversation remoteKeyNumber];
        GLPConversation *syncConversation = _conversations[remoteKey];
        
        if(!syncConversation) {
            DDLogWarn(@"Cannot find sync conversation, abort");
            return;
        }
        
        if(syncConversation.isEnded) {
            DDLogWarn(@"Sync conversation already ended, abort");
            return;
        }
        
        syncConversation.isEnded = YES;
        
        if(syncConversation.isLive) {
            DDLogInfo(@"End conversation that is live, current live conversation count: %d", _liveConversationsCount);
            
            [_liveConversationsEndedOrder enqueue:remoteKey];
            
            // keep to 3 conversations
            while (_liveConversationsCount > 3) {
                NSNumber *toRemoveRemoteKey = [_liveConversationsEndedOrder dequeue];
                [self internalRemoveConversation:_conversations[toRemoveRemoteKey]];
                DDLogInfo(@"Dequeue and remove live conversation with remote key: %@", toRemoveRemoteKey);
                
                // something horrible happened, at least avoid infinite loop
                if(_liveConversationsEndedOrder.count == 0 && _liveConversationsCount > 3) {
                    DDLogError(@"Something horrible happened, at least avoid infinite loop");
                    break;
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    });
}

- (void)randomToRegular:(GLPConversation *)detachedRegularConversation
{
    DDLogInfo(@"Random to regular conversation with remote key: %d", detachedRegularConversation.remoteKey);
    
    dispatch_async(_queue, ^{
        GLPConversation *attachedConversation = [self internalAttachedConversation:detachedRegularConversation];
        if(!attachedConversation) {
            return;
        }
        
        attachedConversation.lastUpdate = detachedRegularConversation.lastUpdate;
        attachedConversation.lastMessage = detachedRegularConversation.lastMessage;
        attachedConversation.participants = detachedRegularConversation.participants;
        attachedConversation.title = detachedRegularConversation.title;
        attachedConversation.isGroup = detachedRegularConversation.isGroup;
        
        attachedConversation.isLive = NO;
        attachedConversation.isEnded = NO;
        attachedConversation.expiryDate = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    });
}

- (void)syncConversation:(GLPConversation *)detachedConversation
{
    DDLogInfo(@"Sync conversation with remote key %d", detachedConversation.remoteKey);
    
    __block GLPMessage *lastSyncMessage = nil;
    __block BOOL shouldSyncContinue = NO;
    
    dispatch_sync(_queue, ^{
        NSNumber *index = [detachedConversation remoteKeyNumber];
        GLPConversation *attachedConversation = [self internalAttachedConversation:detachedConversation];
        if(!attachedConversation) {
            [self internalNotifyConversation:attachedConversation withNewMessages:NO beingPreviousMessages:NO canHaveMorePreviousMessages:NO];
            return;
        }
        
        BOOL valid = [self isConversationForSync:attachedConversation];
        if(!valid) {
            BOOL canHaveMorePreviousMessages = [_conversationsMessages[index] count] > 0 && [_conversationsCanHavePreviousMessages[index] boolValue];
            
            [self internalNotifyConversation:attachedConversation withNewMessages:NO beingPreviousMessages:NO canHaveMorePreviousMessages:canHaveMorePreviousMessages];
            return;
        }
        
        lastSyncMessage = [self internalConversationLastSyncMessage:attachedConversation];
        shouldSyncContinue = YES;
    });
    
    if(!shouldSyncContinue) {
        DDLogWarn(@"Sync should stop now, so stop it");
        return;
    }

    DDLogInfo(@"Last sync message: %d - %@", lastSyncMessage.key, lastSyncMessage.content);
    
    [[WebClient sharedInstance] getMessagesForConversation:detachedConversation after:lastSyncMessage before:nil callbackBlock:^(BOOL success, NSArray *messages) {
        if(!success) {
            [self internalNotifyConversation:detachedConversation withNewMessages:NO beingPreviousMessages:NO canHaveMorePreviousMessages:NO];
            return;
        }
        
        DDLogInfo(@"Received %d messages with success", messages.count);
        
        // reverse order
        messages = [[messages reverseObjectEnumerator] allObjects];
        
        dispatch_async(_queue, ^{
            NSNumber *index = [detachedConversation remoteKeyNumber];
            GLPConversation *attachedConversation = [self internalAttachedConversation:detachedConversation];
            if(!attachedConversation) {
                [self internalNotifyConversation:attachedConversation withNewMessages:NO beingPreviousMessages:NO canHaveMorePreviousMessages:NO];
                return;
            }
            
            BOOL valid = [self isConversationForSync:attachedConversation];
            if(!valid) {
                BOOL canHaveMorePreviousMessages = [_conversationsMessages[index] count] > 0 && [_conversationsCanHavePreviousMessages[index] boolValue];
                
                [self internalNotifyConversation:attachedConversation withNewMessages:NO beingPreviousMessages:NO canHaveMorePreviousMessages:canHaveMorePreviousMessages];
                return;
            }
            
            // verify last message sync is still the same
            GLPMessage *m = [self internalConversationLastSyncMessage:attachedConversation];
            
            if((lastSyncMessage || m) && ![lastSyncMessage isEqualToEntity:m]) {
                DDLogWarn(@"Original last sync message does not match the conversation's current one : %d != %d", lastSyncMessage.key, m.key);
                [self internalNotifyConversation:attachedConversation withNewMessages:NO beingPreviousMessages:NO canHaveMorePreviousMessages:NO];
                return;
            }
            
            BOOL hasNewMessages = messages.count > 0;
            if(hasNewMessages) {
                [self internalInsertMessages:messages toConversation:attachedConversation atTheEnd:YES];
            }
            
            _conversationsSyncStatuses[index] = [NSNumber numberWithBool:YES];
            
            BOOL canHaveMorePreviousMessages = [_conversationsMessages[index] count] > 0 && [_conversationsCanHavePreviousMessages[index] boolValue];

            
//            DDLogInfo(@"Sleep starts");
//            [NSThread sleepForTimeInterval:10];
//            DDLogInfo(@"Sleep ends");
            
            [self internalNotifyConversation:attachedConversation withNewMessages:hasNewMessages beingPreviousMessages:NO canHaveMorePreviousMessages:canHaveMorePreviousMessages];
        });
    }];
}

- (void)syncConversationPreviousMessages:(GLPConversation *)detachedConversation
{
    DDLogInfo(@"Sync conversation previous messages %d", detachedConversation.remoteKey);
    
    __block GLPMessage *oldestMessage = nil;
    
    dispatch_sync(_queue, ^{
        GLPConversation *attachedConversation = [self internalConversationForSyncPreviousMessages:detachedConversation];
        if(!attachedConversation) {
            [self internalNotifyConversation:detachedConversation withNewMessages:NO beingPreviousMessages:YES canHaveMorePreviousMessages:NO];
            return;
        }
        
        oldestMessage = [self internalConversationOldestMessageForSyncPreviousMessages:attachedConversation];
        
        if(!oldestMessage) {
            // abort and notify
            [self internalNotifyConversation:attachedConversation withNewMessages:NO beingPreviousMessages:YES canHaveMorePreviousMessages:NO];
            return;
        }
    });
    
    if(!oldestMessage) {
        DDLogError(@"Cannot found conversation oldest message, abort");
        return;
    }
    
    DDLogInfo(@"Oldest message key: %d - remote key: %d - content: %@", oldestMessage.key, oldestMessage.remoteKey, oldestMessage.content);
    
    [[WebClient sharedInstance] getMessagesForConversation:detachedConversation after:nil before:oldestMessage callbackBlock:^(BOOL success, NSArray *messages) {
        if(!success) {
            [self internalNotifyConversation:detachedConversation withNewMessages:NO beingPreviousMessages:YES canHaveMorePreviousMessages:NO];
            return;
        }
        
        DDLogInfo(@"Received %d messages with success", messages.count);
        
        // reverse order
        messages = [[messages reverseObjectEnumerator] allObjects];
        
        dispatch_async(_queue, ^{
            GLPConversation *attachedConversation = [self internalConversationForSyncPreviousMessages:detachedConversation];
            if(!attachedConversation) {
                [self internalNotifyConversation:detachedConversation withNewMessages:NO beingPreviousMessages:YES canHaveMorePreviousMessages:NO];
                return;
            }
            
            GLPMessage *oldestMessage = [self internalConversationOldestMessageForSyncPreviousMessages:attachedConversation];
            
            GLPMessage *m = [self internalConversationOldestMessageForSyncPreviousMessages:attachedConversation];
            
            if(![oldestMessage isEqualToEntity:m]) {
                DDLogInfo(@"Original oldest message does not match the conversation's current one");
                [self internalNotifyConversation:attachedConversation withNewMessages:NO beingPreviousMessages:YES canHaveMorePreviousMessages:NO];
                return;
            }
            
            BOOL hasNewMessages = messages.count > 0;
            if(hasNewMessages) {
                [self internalInsertMessages:messages toConversation:attachedConversation atTheEnd:NO];
            }
            
            BOOL canHavePreviousMessages = messages.count == 20 ? YES : NO;
            _conversationsCanHavePreviousMessages[[attachedConversation remoteKeyNumber]] = [NSNumber numberWithBool:canHavePreviousMessages];
            
            [self internalNotifyConversation:attachedConversation withNewMessages:hasNewMessages beingPreviousMessages:YES canHaveMorePreviousMessages:canHavePreviousMessages];
        });
    }];
}

// Get converation available for sync, from detached conversation
- (BOOL)internalIsConversationForSync:(GLPConversation *)attachedConversation
{
    if([_conversationsSyncStatuses[[attachedConversation remoteKeyNumber]] boolValue]) {
        DDLogInfo(@"Conversation for sync is already sync");
        return NO;
    }
    
    return YES;
}

// Get converation available for sync, from detached conversation
// TODO: rename internal
- (BOOL)isConversationForSync:(GLPConversation *)attachedConversation
{
    if([_conversationsSyncStatuses[[attachedConversation remoteKeyNumber]] boolValue]) {
        DDLogInfo(@"Conversation for sync is already sync");
        return NO;
    }
    
    return YES;
}

- (GLPConversation *)internalAttachedConversation:(GLPConversation *)detachedConversation
{
    GLPConversation *attachedConversation = _conversations[[detachedConversation remoteKeyNumber]];
    if(!attachedConversation) {
        DDLogError(@"Grave inconsistency: Attached conversation remote key %d does not exist", detachedConversation.remoteKey);
    }
    
    return attachedConversation;
}

// Get newest synced message
// With verification
- (GLPMessage *)internalConversationLastSyncMessage:(GLPConversation *)attachedConversation
{
    if(attachedConversation.lastSyncMessageKey == NSNotFound) {
        DDLogInfo(@"Conversation does not have last synced message");
        return nil;
    }
    
    // conversation has last sync message
    GLPMessage *message = [self internalFindMessageByKey:attachedConversation.lastSyncMessageKey inConversation:attachedConversation];
    
    if(!message) {
        DDLogError(@"Grave inconsistency: Last sync message for key %d not found", attachedConversation.lastSyncMessageKey);
        return nil;
    }
    
    DDLogInfo(@"Conversation last sync message key: %d", message.key);
    return message;
}

- (GLPConversation *)internalConversationForSyncPreviousMessages:(GLPConversation *)detachedConversation
{
    NSNumber *index = [detachedConversation remoteKeyNumber];
    GLPConversation *attachedConversation = _conversations[index];
    if(!attachedConversation) {
        DDLogError(@"Grave inconsistency: Conversation for sync previous messages does not exist");
        return nil;
    }
    
    if(![_conversationsSyncStatuses[index] boolValue]) {
        DDLogWarn(@"Conversation is not synced, and should be before syncing any previous messages");
        return nil;
    }
    
    if(![_conversationsCanHavePreviousMessages[index] boolValue]) {
        DDLogWarn(@"Conversation is marked to don't have any previous messages, abord and send complete notification directly");
        return nil;
    }

    return attachedConversation;
}

- (GLPMessage *)internalConversationOldestMessageForSyncPreviousMessages:(GLPConversation *)attachedConversation
{
    NSNumber *index = [attachedConversation remoteKeyNumber];
    if([_conversationsMessages[index] count] == 0) {
        DDLogWarn(@"Trying to get oldest message for conversation that does not have any messages");
        return nil;
    }
    
    return [_conversationsMessages[index] firstObject];
}



- (void)markNotSynchronized
{
    DDLogInfo(@"Mark conversations not synchronized anymore");
    
    dispatch_async(_queue, ^{
        _isSynchronizedWithRemote = NO;
        
        for(NSNumber *key in [_conversationsSyncStatuses allKeys]) {
            _conversationsSyncStatuses[key] = [NSNumber numberWithBool:NO];
        }
        
        // all messages that were in waiting to send now marked as failed
        for(NSNumber *index in _conversationsMessages) {
            for(GLPMessage *message in _conversationsMessages[index]) {
                if(message.sendStatus == kSendStatusLocal) {
                    message.sendStatus = kSendStatusFailure;
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_NOT_SYNCHRONIZED_WITH_REMOTE object:nil];
    });
}

- (void)resetLastShownMessageForConversation:(GLPConversation *)detachedConversation
{
    DDLogInfo(@"Conversations manager - Reset shown messages for conversation with remote key: %d", detachedConversation.remoteKey);
    
    dispatch_async(_queue, ^{
        GLPConversation *attachedConversation = [self internalAttachedConversation:detachedConversation];
        if(!attachedConversation) {
            return;
        }
        
        NSNumber *index = [attachedConversation remoteKeyNumber];
        _conversationsLastestMessageShown[index] = [NSNumber numberWithInteger:0];
        _conversationsOldestMessageShown[index] = [NSNumber numberWithInteger:0];
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


// BOTH REGULAR AND RANDOM SO FAR
- (GLPConversation *)findRegularByParticipant:(GLPUser *)participant
{
    DDLogInfo(@"Find regular conversation by participant %d - %@", participant.remoteKey, participant.name);
    
    __block GLPConversation *conversation = nil;
    
    dispatch_sync(_queue, ^{
        NSArray *filteredArray = [[_conversations allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            GLPConversation *attachedConversation = evaluatedObject;
            
//            if(attachedConversation.isLive) {
//                return NO;
//            }
            
            GLPUser *attachedParticipant = [attachedConversation.participants firstObject];
            return attachedParticipant.remoteKey == participant.remoteKey;
        }]];
        
        if(filteredArray.count == 0) {
            DDLogInfo(@"Cannot found regular conversation that matches");
            return;
        }
        
        conversation = filteredArray[0];
    });
    
    return conversation;
}

//- (BOOL)isConversationSync:(GLPConversation *)conversation
//{
//    __block BOOL result;
//    
//    dispatch_sync(_queue, ^{
//        NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
//        GLPConversation *syncConversation = _conversations[index];
//        if(!syncConversation) {
//            DDLogWarn(@"Cannot get sync status from non existent conversation");
//            return;
//        }
//        
//        result = [_conversationsSyncStatuses[index] boolValue];
//    });
//    
//    return result;
//}

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

- (BOOL)conversationCanHavePreviousMessages:(GLPConversation *)conversation
{
    __block BOOL res = NO;
    
    dispatch_sync(_queue, ^{
        NSNumber *index = [conversation remoteKeyNumber];
        GLPConversation *syncConversation = _conversations[index];
        if(!syncConversation) {
            return;
        }
        
        res = [_conversationsCanHavePreviousMessages[index] boolValue];
    });
    
    return res;
}

- (GLPConversation *)oldestLiveConversation
{
    __block GLPConversation *oldestConversation = nil;
    
    dispatch_sync(_queue, ^{
        if(_liveConversationsCount < 3) {
            return;
        }
        
        for(NSNumber *remoteKey in _conversations) {
            GLPConversation *conversation = _conversations[remoteKey];
            
            // filter by live and not ended
            if(!conversation.isLive || conversation.isEnded) {
                continue;
            }
            
            if(oldestConversation && [oldestConversation.expiryDate compare:conversation.expiryDate] == NSOrderedAscending) {
                continue;
            }
            
            oldestConversation = conversation;
        }
    });
    
    return oldestConversation;
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

- (NSArray *)lastestMessagesForConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Get lastest messages for conversation remote key: %d", conversation.remoteKey);
    __block NSArray *array = nil;
    
    dispatch_sync(_queue, ^{
        NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
        
        GLPConversation *synchConversation = _conversations[index];
        if(!synchConversation) {
            DDLogError(@"Cannot get lastest messages for non existent conversation");
            return;
        }
        
        NSInteger count = [_conversationsMessages[index] count];
        
        // empty messages
        if(count == 0) {
            DDLogInfo(@"No messages for conversation, abort");
            return;
        }
        
        NSInteger lastShownMessageKey = [_conversationsLastestMessageShown[index] integerValue];
        DDLogInfo(@"Last shown message key: %d", lastShownMessageKey);
        
        NSArray *syncMessages;
        
        // show all messages
        if(lastShownMessageKey == 0) {
            syncMessages = _conversationsMessages[index];
        }
        
        // show messages starting after the last shown
        else {
            NSUInteger syncIndex = [self internalFindMessageIndexByKey:lastShownMessageKey inConversation:synchConversation];
            if(syncIndex == NSNotFound) {
                DDLogError(@"Cannot find the lastest shown message for key %d, abort", lastShownMessageKey);
                return;
            }
            
            if(syncIndex == count - 1) {
                DDLogInfo(@"Lastest shown message is the last message of the conversation, abort");
                return;
            }
            
            NSRange range = NSMakeRange(syncIndex + 1, count - syncIndex - 1);
            DDLogInfo(@"Get messages after index %d. Range is: %d - %d. Messages count is: %d", syncIndex, range.location, range.length, count);
            
            GLPMessage *lastM = _conversationsMessages[index][syncIndex];
            DDLogInfo(@"Last sync message: %@", lastM.content);
            
            // check for out of range errors
            if(range.location + range.length > count) {
                DDLogError(@"ERROR: Messages subarray is out of range, THIS IS WRONG!");
                return;
            }
            
            syncMessages = [_conversationsMessages[index] subarrayWithRange:range];
        }
        
        if(syncMessages.count > 0) {
            GLPMessage *last = [syncMessages lastObject];
            _conversationsLastestMessageShown[index] = [NSNumber numberWithInteger:last.key];
            DDLogInfo(@"New last shown message key: %d", last.key);
            
            // first time, we also intialize the oldest shown message
            if([_conversationsOldestMessageShown[index] isEqualToNumber:@0]) {
               GLPMessage *first = [syncMessages firstObject];
                _conversationsOldestMessageShown[index] = [NSNumber numberWithInteger:first.key];
                DDLogInfo(@"New oldest shown message key: %d", first.key);
            }
        }
        
        // mark conversation as read
        synchConversation.hasUnreadMessages = NO;
        
        array = [[NSArray alloc] initWithArray:syncMessages copyItems:YES];
    });
    
    if(!array) {
        array = [NSArray array];
    }
    
    DDLogInfo(@"Return %d new messages since the last shown message", array.count);
    
    return array;
}

- (NSArray *)oldestMessagesForConversation:(GLPConversation *)detachedConversation
{
    DDLogInfo(@"Get oldest messages for conversation %d", detachedConversation.remoteKey);
    __block NSArray *array = nil;
    
    dispatch_sync(_queue, ^{
        GLPConversation *attachedConversation = [self internalAttachedConversation:detachedConversation];
        if(!attachedConversation) {
            return;
        }
        
        NSNumber *index = [attachedConversation remoteKeyNumber];
        
        NSInteger count = [_conversationsMessages[index] count];
        
        // empty messages
        if(count == 0) {
            DDLogInfo(@"No messages for conversation, abort");
            return;
        }
        
        NSInteger oldestShownMessageKey = [_conversationsOldestMessageShown[index] integerValue];
        DDLogInfo(@"Oldest shown message key: %d", oldestShownMessageKey);
        
        if(oldestShownMessageKey == 0) {
            DDLogInfo(@"There is no oldest shown message, abort");
            return;
        }
        
        NSUInteger oldestMessageIndex = [self internalFindMessageIndexByKey:oldestShownMessageKey inConversation:attachedConversation];
        if(oldestMessageIndex == NSNotFound) {
            DDLogError(@"Grave inconsistency: Cannot find the oldest shown message for key %d, abort", oldestShownMessageKey);
            return;
        }
        
        if(oldestMessageIndex == 0) {
            DDLogInfo(@"Oldest shown message is already the oldest message of the conversation, abort");
            return;
        }
        
        NSRange range = NSMakeRange(0, oldestMessageIndex);
        DDLogInfo(@"Get messages before index %d. Range is: %d - %d. Messages count is: %d", oldestMessageIndex, range.location, range.length, count);
        
        GLPMessage *oldestMessage = _conversationsMessages[index][oldestMessageIndex];
        DDLogInfo(@"Oldest shown message: %@", oldestMessage.content);
        
        // check for out of range errors
        if(range.location + range.length > count) {
            DDLogError(@"ERROR: Messages subarray is out of range, THIS IS WRONG!");
            return;
        }
        
        NSArray *previousMessages = [_conversationsMessages[index] subarrayWithRange:range];
        
        GLPMessage *newOldestMessage = [previousMessages firstObject];
        _conversationsOldestMessageShown[index] = [NSNumber numberWithInteger:newOldestMessage.key];
        DDLogInfo(@"New oldest shown message key: %d", newOldestMessage.key);
        
        array = [[NSArray alloc] initWithArray:previousMessages copyItems:YES];
    });
    
    if(!array) {
        array = [NSArray array];
    }
    
    DDLogInfo(@"Return %d oldest messages since the oldest shown message", array.count);
    
    return array;
}

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

// Local message that has not yet been send to the server
- (void)addLocalMessageToConversation:(GLPMessage *)message
{
    DDLogInfo(@"Add local message \"%@\" to conversation with remote key %d", message.content, message.conversation.remoteKey);
    
    // newly inserted message key
    __block NSInteger key;
    
    dispatch_sync(_queue, ^{
        NSNumber *index = [NSNumber numberWithInteger:message.conversation.remoteKey];
        GLPConversation *conversation = _conversations[index];
        if(!conversation) {
            DDLogError(@"Cannot add new message to non existent conversation");
            return;
        }
        
        key = [self internalAddMessage:message toConversation:conversation];
        
        [self internalNotifyConversationHasNewLocalMessages:conversation];
    });
    
    DDLogInfo(@"New local message successfuly added with key: %d", key);
    message.key = key;
}

// Remote message that is received from the server
- (void)addRemoteMessage:(GLPMessage *)message toConversationWithRemoteKey:(NSInteger)remoteKey
{
    DDLogInfo(@"Add remote message \"%@\" to conversation with remote key %d", message.content, remoteKey);
    
    dispatch_async(_queue, ^{
        NSNumber *index = [NSNumber numberWithInteger:remoteKey];
        GLPConversation *conversation = _conversations[index];
        if(!conversation) {
            DDLogError(@"Cannot add remote message to non existent conversation");
            return;
        }
        
        BOOL newMessagesFromSync = NO;
        
        BOOL hasMessages = [_conversationsMessages[index] count] > 0;
        BOOL sync = [_conversationsSyncStatuses[index] boolValue];
        if(hasMessages && !sync) {
            DDLogInfo(@"Conversation has messages and is not synced, do it before");
            
            GLPMessage *lastSyncMessage = [self internalConversationLastSyncMessage:conversation];
            if(!lastSyncMessage) {
                DDLogError(@"Cannot find last synced message, abort");
                return;
            }
            
            DDLogInfo(@"Last sync message: %d - %@", lastSyncMessage.key, lastSyncMessage.content);
            
            NSArray *messages = [[WebClient sharedInstance] synchronousGetMessagesForConversation:conversation after:lastSyncMessage before:nil];
            
            if(!messages) {
                DDLogError(@"Nil messages response");
                return;
            }
            
            DDLogInfo(@"Received %d messages with success", messages.count);
            
            // reverse order
            messages = [[messages reverseObjectEnumerator] allObjects];
            
            BOOL hasNewMessages = messages.count > 0;
            if(hasNewMessages) {
                [self internalInsertMessages:messages toConversation:conversation atTheEnd:YES];
                newMessagesFromSync = hasMessages;
            }
            
            _conversationsSyncStatuses[index] = [NSNumber numberWithBool:YES];
            DDLogInfo(@"Synced complete");
        }
        
        GLPMessage *existingMessage = [self internalFindMessageByRemoteKey:message.remoteKey inConversation:conversation];
        
        if(!existingMessage) {
            NSInteger key = [self internalAddMessage:message toConversation:conversation];
            conversation.lastSyncMessageKey = key;
            newMessagesFromSync = YES;
        } else {
            DDLogInfo(@"Remote message already exists in conversation's messages, ignore");
        }
        
        if(!newMessagesFromSync) {
            DDLogInfo(@"No new remote messages to notify, abort");
            return;
        }
        
        // conversation has unread messages
        conversation.hasUnreadMessages = YES;
        
        DDLogInfo(@"Notify new messages");
        [self internalNotifyConversation:conversation withNewMessages:YES beingPreviousMessages:NO canHaveMorePreviousMessages:NO];
    });
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

// Update once the local message has been sent
- (void)updateLocalMessageAfterSending:(GLPMessage *)message
{
    DDLogInfo(@"Update local message \"%@\" after sending with key: %d", message.content, message.key);
    
    dispatch_async(_queue, ^{
        GLPConversation *conversation = _conversations[[NSNumber numberWithInteger:message.conversation.remoteKey]];
        if(!conversation) {
            DDLogError(@"Cannot update local message for non existent conversation");
            return;
        }
        
        GLPMessage *synchMessage = [self internalFindMessageByKey:message.key inConversation:conversation];
        if(!synchMessage) {
            DDLogError(@"Cannot update non existent message");
            return;
        }
        
        synchMessage.sendStatus = message.sendStatus;
        
        BOOL sent;
        NSString *sentLog;
        if(message.sendStatus == kSendStatusSent) {
            synchMessage.remoteKey = message.remoteKey;
            conversation.lastSyncMessageKey = synchMessage.key;
            
            sentLog = @"SENT";
            sent = YES;
        } else {
            sentLog = @"NOT SENT";
            sent = NO;
        }
        
        DDLogInfo(@"Local message update completed, with sent status: %@", sentLog);
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_MESSAGE_SEND_UPDATE object:nil userInfo:@{@"key": [NSNumber numberWithInteger:message.key], @"sent":[NSNumber numberWithBool:sent]}];
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
- (GLPMessage *)internalFindMessageByRemoteKey:(NSInteger)remoteKey inConversation:(GLPConversation *)conversation
{
    NSArray *messages = _conversationsMessages[[NSNumber numberWithInteger:conversation.remoteKey]];
    NSUInteger index = [messages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if(((GLPMessage *)obj).remoteKey == remoteKey) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    if(index == NSNotFound) {
        return nil;
    }
    
    return messages[index];
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
        
        // last message key is the new one only if the array represents the last elements of conversation's messages
        conversation.lastSyncMessageKey = key;
    } else {
        [_conversationsMessages[index] insertObjects:synchMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, synchMessages.count)]];
    }
    
    _conversationsMessagesKeys[index] = [NSNumber numberWithInteger:key];
    
    DDLogInfo(@"Successful add messages to conversation, last sync message key: %d", key);
}

- (NSInteger)internalAddMessage:(GLPMessage *)message toConversation:(GLPConversation *)conversation
{
    NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
    
    NSInteger key = [_conversationsMessagesKeys[index] integerValue] + 1;
    
    GLPMessage *synchMessage = [message copy];
    synchMessage.key = key;
    [conversation updateWithNewMessage:message];
    
    [_conversationsMessages[index] addObject:synchMessage];
    
    NSNumber *keyNumber = [NSNumber numberWithInteger:key];
    _conversationsMessagesKeys[index] = keyNumber;
    
    return key;
}

// Internal
// Should be called inside a queue block
- (BOOL)internalAddConversation:(GLPConversation *)conversation isEmpty:(BOOL)isEmpty
{
    NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
    
    // do not add twice the same conversation
    if(_conversations[index]) {
        DDLogWarn(@"Conversation already exists, cannot add twice");
        
        // copy only last message and date, it may have changed (?)
        GLPConversation *existingC = _conversations[index];
        existingC.lastMessage = conversation.lastMessage;
        existingC.lastUpdate = conversation.lastUpdate;
        return NO;
    }
    
    if(conversation.isLive) {
        _liveConversationsCount++;
    } else {
        _regularConversationsCount++;
    }
    
    _conversations[index] = conversation;
    _conversationsMessages[index] = [NSMutableArray array];
    _conversationsSyncStatuses[index] = [NSNumber numberWithBool:NO];
    _conversationsMessagesKeys[index] = [NSNumber numberWithInteger:0];
    _conversationsLastestMessageShown[index] = [NSNumber numberWithInteger:0];
    _conversationsOldestMessageShown[index] = [NSNumber numberWithInteger:0];
    
    // empty conversations don't have previous mesages
    _conversationsCanHavePreviousMessages[index] = [NSNumber numberWithBool:!isEmpty];
    
    return YES;
}

// Internal
// Should be called inside a queue block
- (BOOL)internalRemoveConversation:(GLPConversation *)conversation
{
    NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
    
    if(!_conversations[index]) {
        DDLogWarn(@"Conversation does not exists, cannot remove");
        return NO;
    }
    
    if(conversation.isLive) {
        _liveConversationsCount--;
    } else {
        _regularConversationsCount--;
    }
    
    [_conversations removeObjectForKey:index];
    [_conversationsMessages removeObjectForKey:index];
    [_conversationsSyncStatuses removeObjectForKey:index];
    [_conversationsMessagesKeys removeObjectForKey:index];
    [_conversationsLastestMessageShown removeObjectForKey:index];
    [_conversationsOldestMessageShown removeObjectForKey:index];
    [_conversationsCanHavePreviousMessages removeObjectForKey:index];
    
    return YES;
}

- (void)internalNotifyConversationHasNewLocalMessages:(GLPConversation *)conversation
{
    [self internalNotifyConversation:conversation
                         newMessages:YES
               beingPreviousMessages:NO
         canHaveMorePreviousMessages:NO
                     newLocalMessage:YES];
}

- (void)internalNotifyConversation:(GLPConversation *)conversation withNewMessages:(BOOL)newMessages beingPreviousMessages:(BOOL)previousMessages canHaveMorePreviousMessages:(BOOL)canHaveMorePreviousMessages
{
    [self internalNotifyConversation:conversation
                         newMessages:newMessages
               beingPreviousMessages:previousMessages
         canHaveMorePreviousMessages:canHaveMorePreviousMessages
                     newLocalMessage:NO];
    
//    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:Nil userInfo:@{@"remoteKey":[NSNumber numberWithInteger:conversation.remoteKey], @"newMessages": [NSNumber numberWithBool:newMessages], @"previousMessages": [NSNumber numberWithBool:previousMessages], @"canHaveMorePreviousMessages": [NSNumber numberWithBool:canHaveMorePreviousMessages]}];
}

- (void)internalNotifyConversation:(GLPConversation *)conversation newMessages:(BOOL)newMessages beingPreviousMessages:(BOOL)previousMessages canHaveMorePreviousMessages:(BOOL)canHaveMorePreviousMessages newLocalMessage:(BOOL)newLocalMessage
{
    NSDictionary *args = @{@"remoteKey":[NSNumber numberWithInteger:conversation.remoteKey],
                           @"newMessages": [NSNumber numberWithBool:newMessages],
                           @"previousMessages": [NSNumber numberWithBool:previousMessages],
                           @"canHaveMorePreviousMessages": [NSNumber numberWithBool:canHaveMorePreviousMessages],
                           @"newLocalMessage": [NSNumber numberWithBool:newLocalMessage]};
    
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil userInfo:args];
}


- (void)internalConfigureInitialState
{
    _conversations = [NSMutableDictionary dictionary];
    _conversationsMessages = [NSMutableDictionary dictionary];
    _conversationsSyncStatuses = [NSMutableDictionary dictionary];
    _conversationsMessagesKeys = [NSMutableDictionary dictionary];
    _conversationsLastestMessageShown = [NSMutableDictionary dictionary];
    _conversationsOldestMessageShown = [NSMutableDictionary dictionary];
    _conversationsCanHavePreviousMessages = [NSMutableDictionary dictionary];
    _liveConversationsEndedOrder = [NSMutableArray array];
    _liveConversationsCount = 0;
    _regularConversationsCount = 0;
    
    _successfullyLoaded = NO;
    _isSynchronizedWithRemote = NO;
    _areConversationsSync = NO;
}

@end
