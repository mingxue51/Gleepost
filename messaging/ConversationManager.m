//
//  ConversationManager.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ConversationManager.h"


#import "GLPLiveConversationsManager.h"
#import "GLPConversationDao.h"
#import "GLPMessageDao.h"
#import "GLPLiveConversationDao.h"
#import "UserManager.h"
#import "SessionManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "MessagesSendingProcessor.h"
#import "NSDate+UTC.h"
#import "DatabaseManager.h"
#import "GLPUserDao.h"
#import "NSNotificationCenter+Utils.h"
#import "GLPMessageProcessor.h"

@implementation ConversationManager

int const NumberMaxOfMessagesLoaded = 20;

#pragma mark - New methods

+ (NSArray *)loadLocalRegularConversations
{
    __block NSArray *conversations = nil;
//    [DatabaseManager run:^(FMDatabase *db) {
//        conversations = [GLPConversationDao findConversationsOrderByDateInDb:db];
//    }];
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        conversations = [GLPConversationDao findConversationsOrderByDateInDb:db];
    }];
    

    return conversations;
}

+ (void)saveOrUpdateConversation:(GLPConversation *)conversation
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPConversationDao saveIfNotExist:conversation db:db];

    }];
}

+ (void)initialSaveConversationsToDatabase:(NSArray *)conversations
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        DDLogDebug(@"DB error : initialSaveConversationsToDatabase");
        
        [GLPConversationDao deleteAllNormalConversationsInDb:db];

        for(GLPConversation *conversation in conversations)
        {
            [GLPConversationDao saveIfNotExist:conversation db:db];
        }
        
    }];
}

+ (void)deleteConversation:(GLPConversation *)conversation
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPConversationDao deleteConversationWithRemoteKey:conversation.remoteKey db:db];
        [GLPMessageDao deleteMessagesForConversation:conversation db:db];
    }];
}

+ (void)initialSaveMessagesToDatabase:(NSArray *)messages
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        for(GLPMessage *message in messages)
        {
            GLPMessage *m = [GLPMessageDao findByRemoteKey:message.remoteKey db:db];
            
            if(m)
            {
                continue;
            }
            
            [GLPMessageDao save:message db:db];
        }
    }];
}

+ (NSArray *)loadLatestMessagesForConversation:(GLPConversation *)conversation
{
    __block NSArray *messages = nil;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        messages = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
    }];
    
    return messages;
}

+ (NSArray *)loadPreviousMessagesBefore:(GLPMessage *)message forConversation:(GLPConversation *)conversation
{
    __block NSArray *previousMessages = nil;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        previousMessages = [GLPMessageDao findPreviousMessagesBefore:message db:db];
    }];
    
    return previousMessages;
}

+ (void)saveNewMessage:(GLPMessage *)message withConversation:(GLPConversation *)conversation
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        message.conversation = conversation;
        [GLPMessageDao save:message db:db];
    }];
}

#pragma mark - Old methods

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback
{
    NSArray *localEntities = [ConversationManager loadLocalRegularConversations];
    localCallback(localEntities);
    NSLog(@"Load local conversations %d", localEntities.count);
    
    [[WebClient sharedInstance] getConversationsFilterByLive:NO withCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            [GLPConversationDao deleteAllNormalConversationsInDb:db];
            for(GLPConversation *conversation in conversations) {
                [GLPConversationDao save:conversation db:db];
            }
        }];
        
        remoteCallback(YES, conversations);
        NSLog(@"Load remote conversations %d", conversations.count);
    }];
}

+ (void)markConversationRead:(GLPConversation *)conversation
{
    NSAssert(!conversation.isLive, @"Cannot update read status for live conversation because they are not persisted in local database");
    
    conversation.hasUnreadMessages = NO;
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPConversationDao updateConversationUnreadStatus:conversation db:db];
    }];
}

+(void)loadConversationWithParticipant:(int)remoteKey withCallback:(void (^) (BOOL sucess, GLPConversation* conversation))callback
{
    __block GLPConversation *localConversation = nil;
    
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        GLPUser *currentUser = [GLPUserDao findByRemoteKey:remoteKey db:db];
        localConversation = [GLPConversationDao findByParticipantKey:currentUser.key db:db];
        
    }];
    
    if(localConversation)
    {
        callback(YES, localConversation);
    }
    else
    {
        callback(NO, localConversation);
    }
    
    DDLogInfo(@"Existed local conversation with id: %d", localConversation.key);
    
}

//+ (NSArray *)loadMessagesForConversation:(GLPConversation *)conversation
//{
//    DDLogInfo(@"Load messages for conversation %d", conversation.remoteKey);
//    
//    __block NSArray *localEntities = nil;
//    
//    if(conversation.isLive) {
//        localEntities = [[GLPLiveConversationsManager sharedInstance] messagesForConversation:conversation];
//    } else {
//        [DatabaseManager run:^(FMDatabase *db) {
//            localEntities = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
//        }];
//    }
//    
//    DDLogInfo(@"Loaded messages from local: %d", localEntities.count);
//    
//    return localEntities;
//}

+ (void)loadPreviousMessagesForConversation:(GLPConversation *)conversation before:(GLPMessage *)message localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback
{
    DDLogInfo(@"Load previous messages, before %@", message.content);
    
    [[WebClient sharedInstance] getMessagesForConversation:conversation after:nil before:message callbackBlock:^(BOOL success, NSArray *messages) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        // update only if new changes from API
        if(!messages || messages.count == 0) {
            remoteCallback(YES, nil);
            return;
        }
        
        DDLogInfo(@"New remote messages %d", messages.count);
        
        // reverse order
        messages = [[messages reverseObjectEnumerator] allObjects];
        
        if(conversation.isLive) {
            [[GLPLiveConversationsManager sharedInstance] addMessages:messages toConversation:conversation before:message];
        } else {
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                for(GLPMessage *message in messages) {
                    [GLPMessageDao save:message db:db];
                }
            }];
        }
        
        remoteCallback(YES, messages);
    }];
}

//+ (NSArray *)loadMessagesForConversation:(GLPConversation *)conversation
//{
//    DDLogInfo(@"Load messages for conversation %d", conversation.remoteKey);
//    
//    __block NSArray *localEntities = nil;
//    
//    if(conversation.isLive) {
//        localEntities = [[GLPLiveConversationsManager sharedInstance] messagesForConversation:conversation];
//    } else {
//        [DatabaseManager run:^(FMDatabase *db) {
//            localEntities = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
//        }];
//    }
//    
//    DDLogInfo(@"Loaded messages from local: %d", localEntities.count);
//    
//    return localEntities;
//}

+ (void)loadMessagesForConversation:(GLPConversation *)conversation localCallback:(void (^)(NSArray *messages, BOOL isFinal))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback
{
    DDLogInfo(@"Load messages for conversation %d", conversation.remoteKey);
    
    __block NSArray *localEntities = nil;
    
    if(conversation.isLive) {
        localEntities = [[GLPLiveConversationsManager sharedInstance] messagesForConversation:conversation];
    } else {
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            localEntities = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
        }];
    }
    
    DDLogInfo(@"Loaded messages from local: %d", localEntities.count);
    
    if(localEntities.count >= 20) {
        localCallback(localEntities, YES);
        return;
    }
    
    localCallback(localEntities, NO);
    
    GLPMessage *last = nil;
    for (int i = localEntities.count - 1; i >= 0; i--) {
        GLPMessage *message = localEntities[i];
        if(message.remoteKey != 0) {
            last = message;
            break;
        }
    }
    
    NSLog(@"last local message synch with remote: %d - %@", last.remoteKey, last.content);
    
    [[WebClient sharedInstance] getMessagesForConversation:conversation after:last before:Nil callbackBlock:^(BOOL success, NSArray *messages) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        // uncomment for debug, simulate responses with at least 1 new remote message
//        if(last) {
//            GLPMessage *m = [[GLPMessage alloc] init];
//            m.content = @"new fake msg 1";
//            m.author = last.author;
//            m.date = [last.date dateByAddingTimeInterval:5];
//            m.conversation = last.conversation;
//
//            GLPMessage *m2 = [[GLPMessage alloc] init];
//            m2.content = @"new fake msg 2";
//            m2.author = last.author;
//            m2.date = [last.date dateByAddingTimeInterval:10];
//            m2.conversation = last.conversation;
//            messages = @[m, m2];
//            remoteCallback(YES, messages);
//            return;
//        }
        
        // update only if new changes from API
        if(!messages || messages.count == 0) {
            remoteCallback(YES, nil);
            return;
        }
        
        NSLog(@"new remote messages %d", messages.count);
        
        // reverse order
        messages = [[messages reverseObjectEnumerator] allObjects];
        
        GLPMessage *lastMessage = [messages lastObject];
        [conversation updateWithNewMessage:lastMessage];
        
        if(conversation.isLive) {
            [conversation.messages addObjectsFromArray:messages];
            //[[GLPLiveConversationsManager sharedInstance] add];
        } else {
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                for(GLPMessage *message in messages) {
                    [GLPMessageDao save:message db:db];
                }
                
                [GLPConversationDao updateConversationLastUpdateAndLastMessage:conversation db:db];
                
                //allMessages = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
            }];
        }
        
        remoteCallback(YES, messages);
    }];
    
//    [[WebClient sharedInstance] getLastMessagesForConversation:conversation withLastMessage:last callbackBlock:^(BOOL success, NSArray *messages) {
//        if(!success) {
//            remoteCallback(NO, nil);
//            return;
//        }
//        
//        // uncomment for debug, simulate responses with at least 1 new remote message
////        if(last) {
////            GLPMessage *m = [[GLPMessage alloc] init];
////            m.content = @"new fake msg 1";
////            m.author = last.author;
////            m.date = [last.date dateByAddingTimeInterval:5];
////            m.conversation = last.conversation;
////            
////            GLPMessage *m2 = [[GLPMessage alloc] init];
////            m2.content = @"new fake msg 2";
////            m2.author = last.author;
////            m2.date = [last.date dateByAddingTimeInterval:10];
////            m2.conversation = last.conversation;
////            messages = @[m, m2];
////            remoteCallback(YES, messages);
////            return;
////        }
//        
//        // update only if new changes from API
//        if(!messages || messages.count == 0) {
//            remoteCallback(YES, nil);
//            return;
//        }
//        
//        NSLog(@"new remote messages %d", messages.count);
//        
//        // reverse order
//        messages = [[messages reverseObjectEnumerator] allObjects];
//        
////        // all messages, including the new ones
////        __block NSArray *allMessages = nil;
//        
//        GLPMessage *lastMessage = [messages lastObject];
//        [conversation updateWithNewMessage:lastMessage];
//        
//        if(conversation.isLive) {
//            [conversation.messages addObjectsFromArray:messages];
//            //[[GLPLiveConversationsManager sharedInstance] add];
//        } else {
//            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//                for(GLPMessage *message in messages) {
//                    [GLPMessageDao save:message db:db];
//                }
//                
//                [GLPConversationDao updateConversationLastUpdateAndLastMessage:conversation db:db];
//                
//                //allMessages = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
//            }];
//        }
//        
//        remoteCallback(YES, messages);
//    }];
}

+ (void)loadPreviousMessagesBefore:(GLPMessage *)message callback:(void (^)(BOOL success, BOOL remains, NSArray *messages))callback
{
    NSLog(@"load previous messages before %d - %@", message.key, message.content);
    
    __block NSArray *localEntities = nil;
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        localEntities = [GLPMessageDao findPreviousMessagesBefore:message db:db];
    }];
    
    NSLog(@"local previous messages %d", localEntities.count);
    
    if(localEntities.count > 0) {
        // delay for infime ms because fuck ios development
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            callback(YES, YES, localEntities);
        });
        
        return;
    }
    
    // load more from web
    if(localEntities.count < 15) {
        [[WebClient sharedInstance] getPreviousMessagesBefore:message callbackBlock:^(BOOL success, NSArray *messages) {
            
            if(!success) {
                callback(NO, NO, nil);
                return;
            }
            
            // uncomment for debug, simulate responses with at least 1 new remote message
//            GLPMessage *m = [[GLPMessage alloc] init];
//            m.content = @"new prev fake msg 2";
//            m.author = message.author;
//            m.date = [message.date dateByAddingTimeInterval:-15];
//            m.conversation = message.conversation;
//            
//            GLPMessage *m2 = [[GLPMessage alloc] init];
//            m2.content = @"new prev fake msg 1";
//            m2.author = message.author;
//            m2.date = [message.date dateByAddingTimeInterval:-10];
//            m2.conversation = message.conversation;
//            messages = @[m, m2];
//            callback(YES, NO, messages);
//            return;
            
            NSLog(@"previous messages from web %d", messages.count);
            BOOL remains = messages.count == NumberMaxOfMessagesLoaded;
            
            // reverse order
            messages = [[messages reverseObjectEnumerator] allObjects];
            
            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
                for(GLPMessage *m in messages) {
                    m.isOld = YES;
                    [GLPMessageDao save:m db:db];
                }
            }];
            
            callback(YES, remains, messages);
        }];
    }
}

+ (void)createMessageWithContent:(NSString *)content toConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Create message with content %@", content);
    
    __block GLPMessage *message = [[GLPMessage alloc] init];
    message.content = content;
    message.conversation = conversation;
    message.date = [NSDate dateInUTC];
    message.author = [SessionManager sharedInstance].user;
    message.sendStatus = kSendStatusLocal;
    message.seen = YES;
    
    [[GLPLiveConversationsManager sharedInstance] addLocalMessageToConversation:message];
    
    // post message to server
    [[GLPMessageProcessor sharedInstance] processLocalMessage:message];
    
//    if(conversation.isLive) {
//        [[GLPLiveConversationsManager sharedInstance] addNewMessageToConversation:message];
//    } else {
//        [conversation updateWithNewMessage:message];
//        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            [GLPMessageDao save:message db:db];
//            [GLPConversationDao updateConversationLastUpdateAndLastMessage:conversation db:db];
//        }];
//    }

    

}

//+ (void)createMessageWithContent:(NSString *)content toConversation:(GLPConversation *)conversation localCallback:(void (^)(GLPMessage *localMessage))localCallback
//{
//    DDLogInfo(@"Create message with content %@", content);
//    
//    __block GLPMessage *message = [[GLPMessage alloc] init];
//    message.content = content;
//    message.conversation = conversation;
//    message.date = [NSDate dateInUTC];
//    message.author = [SessionManager sharedInstance].user;
//    message.sendStatus = kSendStatusLocal;
//    message.seen = YES;
//    
//    if(conversation.isLive) {
//        [[GLPLiveConversationsManager sharedInstance] addNewMessageToConversation:message];
//    } else {
//        [conversation updateWithNewMessage:message];
//        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            [GLPMessageDao save:message db:db];
//            [GLPConversationDao updateConversationLastUpdateAndLastMessage:conversation db:db];
//        }];
//    }
//    
//    // post message to local
//    localCallback(message);
//    
//    // post message to server
//    [[GLPMessageProcessor sharedInstance] processLocalMessage:message];
//}

// Save message from websocket event
// Executed in background
//+ (void)saveMessageFromWebsocket:(GLPMessage *)message forConversationRemoteKey:(int)remoteKey
//{
//    DDLogInfo(@"Save message \"%@\" from websocket for conversation remote key: %d", message.content, remoteKey);
//    
//    GLPConversation *conversation = [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:remoteKey];
//    
//    if(!conversation) {
//        DDLogError(@"Conversation does not exist, abort");
//        return;
//    }
//    
//    message.conversation = conversation;
//    [[GLPLiveConversationsManager sharedInstance] addNewMessageToConversation:message];
//}

// Save message from websocket event
// Executed in background
+ (void)saveMessage:(GLPMessage *)message forConversationRemoteKey:(int)remoteKey
{
    __block GLPConversation *conversation = nil;
    
    // check if the conversation exists in live conversations
    conversation = [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:remoteKey];
    DDLogInfo(@"Conversation is live: %d", conversation != nil);
    
    if(conversation) {
        [ConversationManager saveMessage:message forConversation:conversation];
        return;
    }
    
    // conversation exists in regular conversation
//    [DatabaseManager run:^(FMDatabase *db) {
//        conversation = [GLPConversationDao findByRemoteKey:remoteKey db:db];
//    }];
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        conversation = [GLPConversationDao findByRemoteKey:remoteKey db:db];
    }];
    DDLogInfo(@"Conversation is normal: %d", conversation != nil);
    
    if(conversation) {
        [ConversationManager saveMessage:message forConversation:conversation];
        return;
    }
    
    DDLogError(@"Conversation does not exists for message \"%@\", abort", message.content);
    
    
//    NSLog(@"Conversation is neither live or normal, request details");
//    
//    // request more details on conversation
//    [[WebClient sharedInstance] synchronousGetConversationForRemoteKey:remoteKey withCallback:^(BOOL success, GLPConversation *remoteConversation) {
//        if(!success) {
//            NSLog(@"Cannot get conversation details, abort and ignore the message");
//            return;
//        }
//        
//        // new live conversation
//        if(remoteConversation.isLive) {
//            // new live conversation, while we already have 3
//            if([[GLPLiveConversationsManager sharedInstance] conversationsCount] == 3) {
//                
//                // get the 3 live conversations that are defined by the api
//                [[WebClient sharedInstance] synchronousGetConversationsFilterByLive:YES withCallback:^(BOOL success, NSArray *remoteLiveConversations) {
//                    if(!success) {
//                        NSLog(@"Cannot get live conversation list, abort and ignore the message");
//                        return;
//                    }
//                    
//                    // message conversation must be a part of the 3
//                    NSArray *containsConversationArray = [remoteLiveConversations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey = %d", conversation.remoteKey]];
//                    
//                    if(containsConversationArray.count == 0) {
//                        NSLog(@"Message's conversation is not part of the 3 live conversations of the user, abort and ignore the message");
//                        return;
//                    }
//                    
//                    [[GLPLiveConversationsManager sharedInstance] setConversations:[remoteLiveConversations mutableCopy]];
//                }];
//            }
//        }
//        
//        // otherwise, new regular conversation
//        else {
//            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//                [GLPConversationDao save:remoteConversation db:db];
//            }];
//        }
//        
//        conversation = remoteConversation;
//    }];


}

+ (void)saveMessage:(GLPMessage *)message forConversation:(GLPConversation *)conversation
{
    message.conversation = conversation;
    __block BOOL success = NO;
    
    if(message.conversation.isLive) {
        NSArray *containsMessageArray = [message.conversation.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteKey = %d", message.remoteKey]];
        
        if(containsMessageArray.count != 0) {
            NSLog(@"Message for live conversation already present, abort");
            return;
        }
        
        success = YES;
    }
    
    else {
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            // check message not already exists = long poll own message
            GLPMessage *existingMessage = [GLPMessageDao findByRemoteKey:message.remoteKey db:db];
            if(existingMessage) {
                NSLog(@"Insert message that already exists with the remote key %d : %@", message.remoteKey, message.content);
                return;
            }
            
            message.conversation.lastMessage = message.content;
            message.conversation.lastUpdate = message.date;
            message.conversation.hasUnreadMessages = YES;
            
            [GLPConversationDao update:message.conversation db:db];
            [GLPMessageDao save:message db:db];
            
            success = YES;
        }];
    }
    
    if(success) {
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:GLPNOTIFICATION_NEW_MESSAGE object:nil userInfo:@{@"message":message}];
    }
}

// Save conversation from websocket event
// Executed in background
+ (void)saveConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Save conversation with remote key %d", conversation.remoteKey);
    
    if(conversation.isLive) {
        DDLogError(@"Save live conversation, ignore for now");
        //[GLPLiveConversationsManager sharedInstance] a
    } else {
        DDLogInfo(@"Save regular conversation");
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            [GLPConversationDao save:conversation db:db];
//        }];
        
        //Edited by Silouanos.
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            [GLPConversationDao saveIfNotExist:conversation db:db];
        }];
    }
}

+(void)saveConversationIfNotExist:(GLPConversation *)conversation
{
    DDLogInfo(@"Save conversation if not exist with remote key %d", conversation.remoteKey);
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPConversationDao saveIfNotExist:conversation db:db];
    }];
    
}

// Send message
// Executed in background, from GLPNewMessageProcessorOperation
+ (void)sendMessage:(GLPMessage *)message
{
    DDLogInfo(@"Post message %@ to server, with key: %d", message.content, message.key);
    
    [[WebClient sharedInstance] createMessageSynchronously:message callback:^(BOOL success, NSInteger remoteKey) {
        DDLogInfo(@"Message with key %d posted to server. Success: %d. New remote key: %d", message.key, success, remoteKey);
        
        if(success) {
            message.remoteKey = remoteKey;
            message.sendStatus = kSendStatusSent;
            
            
        } else {
            message.sendStatus = kSendStatusFailure;
        }
        
        [[GLPLiveConversationsManager sharedInstance] updateLocalMessageAfterSending:message];
    }];
}

+(GLPConversation*)createFakeConversationWithParticipants:(NSArray*)participants
{
    GLPConversation *fakeConversation = [[GLPConversation alloc] initWithParticipants:participants];
    GLPUser *participant = [participants objectAtIndex:0];
    
    fakeConversation.title = participant.name;
    
    return fakeConversation;
}


@end
