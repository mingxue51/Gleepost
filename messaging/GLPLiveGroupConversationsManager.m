//
//  GLPLiveGroupConversationsManager.m
//  Gleepost
//
//  Created by Silouanos on 11/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPLiveGroupConversationsManager.h"
#import "WebClient.h"
#import "NSNotificationCenter+Utils.h"
#import "ConversationManager.h"
#import "GLPMessageProcessor.h"

@interface GLPLiveGroupConversationsManager ()

@property (strong, nonatomic) NSMutableDictionary *conversations;
@property (strong, nonatomic) NSMutableDictionary *conversationsMessages;
@property (strong, nonatomic) NSMutableDictionary *conversationsSyncStatuses;
@property (strong, nonatomic) NSMutableDictionary *conversationsMessagesKeys;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSMutableDictionary *conversationsLastestMessageShown;
@property (strong, nonatomic) NSMutableDictionary *conversationsOldestMessageShown;
@property (strong, nonatomic) NSMutableDictionary *conversationsCanHavePreviousMessages;
@property (strong, nonatomic) NSMutableArray *liveConversationsEndedOrder;
@property (assign, nonatomic) NSInteger liveConversationsCount;
@property (assign, nonatomic) NSInteger regularConversationsCount;
@property (assign, nonatomic) BOOL successfullyLoaded;
@property (assign, nonatomic) BOOL isSynchronizedWithRemote;
@property (assign, nonatomic) BOOL areConversationsSync;

@end

@implementation GLPLiveGroupConversationsManager

static GLPLiveGroupConversationsManager *instance = nil;

+ (GLPLiveGroupConversationsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GLPLiveGroupConversationsManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _queue = dispatch_queue_create("com.gleepost.queue.livegroupconversation", DISPATCH_QUEUE_SERIAL);
    [self internalConfigureInitialState];
    [self configureNotifications];

    return self;
}

- (void)clear
{
    dispatch_async(_queue, ^{
        [self internalConfigureInitialState];
    });
}

#pragma mark - Configuration

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

- (void)configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageMessageUploaded:) name:GLPNOTIFICATION_CHAT_IMAGE_UPLOADED object:nil];
}

#pragma mark - Basics

- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey
{
    __block GLPConversation *conversation = nil;
    
    dispatch_sync(_queue, ^{
        conversation = _conversations[[NSNumber numberWithInteger:remoteKey]];
    });
    
    return conversation;
}

#pragma mark - Client

- (void)loadConversationWithRemoteKey:(NSInteger)conversationRemoteKey
{
    DDLogInfo(@"Load group conversation remote key %ld", (long)conversationRemoteKey);
    
    if(conversationRemoteKey == 0)
    {
        return;
    }
    
    dispatch_async(_queue, ^{
    
        [self showLoadingIndicator];
        
        [[WebClient sharedInstance] getConversationForRemoteKey:conversationRemoteKey withCallback:^(BOOL success, GLPConversation *conversation) {
        
//            dispatch_async(_queue, ^{
            
                if(!success) {
                    DDLogError(@"Cannot load group conversation");
                    _isSynchronizedWithRemote = NO;
                    [self hideLoadingIndicator];
                    return;
                }
                
                [self hideLoadingIndicator];
                
                DDLogInfo(@"Load conversation success");
                
                //If the conversation has 1 participant (in case of one member) for now don't add conversation. //Now we don't want to use that for now.
//                if(conversation)
//                {
                [self internalAddConversation:conversation isEmpty:NO];
//                }
                
                _isSynchronizedWithRemote = YES;
                
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_SYNCHRONIZED_WITH_REMOTE object:nil];
                
//            });
            
            if(success && conversation)
            {
                //We should not save conversation in database in 2 blocks. That's why we are saving it here.
                [ConversationManager saveOrUpdateConversation:conversation];
            }

        }];
    });
}

- (void)loadConversationsWithGroups:(NSArray *)groups
{
    [self loadConversationsFromDatabase];    
}

#pragma mark - Image Messages

- (void)imageMessageUploaded:(NSNotification *)notification
{
    NSString *timestamp = notification.userInfo[@"timestamp"];
    NSString *imageUrl = notification.userInfo[@"image_url"];
    
    for(NSNumber *conversationRemoteKey in self.conversationsMessages)
    {
        NSArray *conversationMessages = self.conversationsMessages[conversationRemoteKey];
        
        for(GLPMessage *message in conversationMessages)
        {
            if([message isImageMessage] && [timestamp isEqualToString:[message getContentFromMediaContent]])
            {
                DDLogDebug(@"GLPLiveGroupConversationsManager imageMessageUploaded message %@ url %@", message, imageUrl);
                message.content = [GLPMessage formatMessageWithKindOfMedia:kImageMessage withContent:imageUrl];
                [[GLPMessageProcessor sharedInstance] processLocalMessage:message];
            }
        }
    }
}

# pragma mark - Conversations database

- (void)loadConversationsFromDatabase
{
    DDLogInfo(@"Load local group conversations from database");
    
    NSArray *localConversations = [ConversationManager loadLocalGroupConversations];
    
    dispatch_async(_queue, ^{
        
        for(GLPConversation *conversation in localConversations)
        {
            [self internalAddConversation:conversation isEmpty:NO];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_CONVERSATIONS_SYNC object:nil];
    });
}

#pragma mark - Modifiers

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

#pragma mark - Operations

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
        
        //Save messages to initial messages to local database.
        [ConversationManager initialSaveMessagesToDatabase:messages];
        
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
            
            //TODO: Temporary removed to fix a bug. https://www.pivotaltracker.com/story/show/75096330
            BOOL canHaveMorePreviousMessages = [_conversationsMessages[index] count] > 0 && [_conversationsCanHavePreviousMessages[index] boolValue];
            
            
            //            DDLogInfo(@"Sleep starts");
            //            [NSThread sleepForTimeInterval:10];
            //            DDLogInfo(@"Sleep ends");
            
            //TODO: Temporary removed to fix a bug. https://www.pivotaltracker.com/story/show/75096330
            //            [self internalNotifyConversation:attachedConversation withNewMessages:hasNewMessages beingPreviousMessages:NO canHaveMorePreviousMessages:canHaveMorePreviousMessages];
            
            //Replaced by calling directly the notification method and making the newLocalMessage as YES in order
            //to avoid useless inrernal notification caused by GLPTabBarViewController.
            [self internalNotifyConversation:attachedConversation
                                 newMessages:hasNewMessages
                       beingPreviousMessages:NO
                 canHaveMorePreviousMessages:canHaveMorePreviousMessages
                             newLocalMessage:YES];
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

#pragma mark - Messages

// Local message that has not yet been send to the server
- (void)addLocalMessageToConversation:(GLPMessage *)message
{
    DDLogInfo(@"Add local message \"%@\" to conversation with remote key %ld", message.content, (long)message.conversation.remoteKey);
    
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
    
    DDLogInfo(@"New local message successfuly added with key: %ld", (long)key);
    message.key = key;
}

// Remote message that is received from the server
- (void)addRemoteMessage:(GLPMessage *)message toConversationWithRemoteKey:(NSInteger)remoteKey
{
    DDLogInfo(@"Add remote message \"%@\" to conversation with remote key %d", message.content, remoteKey);
    
    dispatch_async(_queue, ^{
        NSNumber *index = [NSNumber numberWithInteger:remoteKey];
        GLPConversation *conversation = _conversations[index];
        DDLogDebug(@"Conversation last message %@", conversation.lastMessage);
        if(!conversation) {
            DDLogError(@"Cannot add remote message to non existent conversation");
            return;
        }
        
//        [ConversationManager saveNewMessage:message withConversation:conversation];
        
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
        //TODO: COMMENTED OUT that because sometimes the internalInsertMessages was called before showing the latest message to conversation. I don't now if that's good but we will see.
        //        GLPMessage *existingMessage = [self internalFindMessageByRemoteKey:message.remoteKey inConversation:conversation];
        
        GLPMessage *existingMessage = nil;
        
        //If message is saved (so internalInsertMessages called) then avoid to add it twice by looking if the
        //message is already there.
        if(!newMessagesFromSync)
        {
            existingMessage = [self internalFindMessageByRemoteKey:message.remoteKey inConversation:conversation];
        }
        
        DDLogDebug(@"Existing message with remote key %ld new message for synch %d", (long)existingMessage.remoteKey, newMessagesFromSync);
        
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
        ++conversation.unreadMessagesCount;
        
        DDLogInfo(@"Notify new messages");
        //WARNING: The canHaveMorePreviousMessages was NO before. But that was causing an issue where
        //the user was unable to load previous messages after he sent a message.
        //Update retrieved to the old attribute.
        [self internalNotifyConversation:conversation withNewMessages:YES beingPreviousMessages:NO canHaveMorePreviousMessages:NO];
    });
}

// Update once the local message has been sent
- (void)updateLocalMessageAfterSending:(GLPMessage *)message
{
    DDLogInfo(@"Update local message \"%@\" after sending with key: %ld", message.content, (long)message.key);
    
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
        
        //We have updated_content attribute only in case the message is media message.
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_MESSAGE_SEND_UPDATE object:nil userInfo:@{@"key": [NSNumber numberWithInteger:message.key], @"remote_key": [NSNumber numberWithInteger:message.remoteKey], @"sent":[NSNumber numberWithBool:sent], @"updated_content":message.content}];
    });
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
                DDLogInfo(@"New oldest shown message key: %d %@", first.key, first.content);
            }
        }
        
        // mark conversation as read
        synchConversation.hasUnreadMessages = NO;
        synchConversation.unreadMessagesCount = 0;
        
        array = [[NSArray alloc] initWithArray:syncMessages copyItems:YES];
        
        //        DDLogDebug(@"Final Messages %@", array);
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

- (void)markConversation:(GLPConversation *)conversation upToTheLastMessageAsRead:(GLPMessage *)lastMessage
{
    DDLogInfo(@"Mark message %@ as read.", lastMessage.content);
    
    [[WebClient sharedInstance] markConversationWithRemoteKeyAsRead:conversation.remoteKey upToMessageWithRemoteKey:lastMessage.remoteKey callback:^(BOOL success) {
        
        if(success)
        {
            DDLogDebug(@"Up to message %@ read.", lastMessage);
        }
        
    }];
}

- (NSArray *)loadLatestMessagesForConversation:(GLPConversation *)conversation
{
    return [ConversationManager loadLatestMessagesForConversation:conversation];
}

# pragma mark - Internal

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


- (NSInteger)internalAddMessage:(GLPMessage *)message toConversation:(GLPConversation *)conversation
{
    NSNumber *index = [NSNumber numberWithInteger:conversation.remoteKey];
    
    NSInteger key = [_conversationsMessagesKeys[index] integerValue] + 1;
    
    GLPMessage *synchMessage = [message copy];
    synchMessage.key = key;
    [conversation updateWithNewMessage:message];
    
    //Update conversation in local database.
//    [ConversationManager saveOrUpdateConversation:conversation];
    
    [_conversationsMessages[index] addObject:synchMessage];
    
    NSNumber *keyNumber = [NSNumber numberWithInteger:key];
    _conversationsMessagesKeys[index] = keyNumber;
    
    return key;
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

- (GLPConversation *)internalAttachedConversation:(GLPConversation *)detachedConversation
{
    GLPConversation *attachedConversation = _conversations[[detachedConversation remoteKeyNumber]];
    if(!attachedConversation) {
        DDLogError(@"Grave inconsistency: Attached conversation remote key %d does not exist", detachedConversation.remoteKey);
    }
    
    return attachedConversation;
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

#pragma mark - Notifications

- (void)internalNotifyConversationHasNewLocalMessages:(GLPConversation *)conversation
{
    //WARNING: The canHaveMorePreviousMessages was NO before. But that was causing an issue where
    //the user was unable to load previous messages after he sent a message.
    //Update retrieved to the old attribute.
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
                           @"newLocalMessage": [NSNumber numberWithBool:newLocalMessage],
                           @"belongsToGroup" : @(YES)};
    
    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_ONE_CONVERSATION_SYNC object:nil userInfo:args];
}

#pragma mark - UI

- (void)showLoadingIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideLoadingIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
