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

@implementation ConversationManager

int const NumberMaxOfMessagesLoaded = 20;

+ (NSArray *)getLocalNormalConversations
{
    __block NSArray *conversations = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        conversations = [GLPConversationDao findConversationsOrderByDateFilterByLive:NO inDb:db];
    }];
    
    return conversations;
}

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback
{
    NSArray *localEntities = [ConversationManager getLocalNormalConversations];
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

+ (void)loadLiveConversationsWithCallback:(void (^)(BOOL success, NSArray *conversations))callback
{
    [[WebClient sharedInstance] getConversationsFilterByLive:YES withCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            callback(NO, nil);
            return;
        }
        
        callback(YES, conversations);
    }];
}


+ (void)loadMessagesForConversation:(GLPConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback
{
    NSLog(@"load messages for conversation %d", conversation.remoteKey);
    
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
    }];
    
    localCallback(localEntities);
    NSLog(@"local messages %d", localEntities.count);
    
    GLPMessage *last = nil;
    for (int i = localEntities.count - 1; i >= 0; i--) {
        GLPMessage *message = localEntities[i];
        if(message.remoteKey != 0) {
            last = message;
            break;
        }
    }
    
    NSLog(@"last local message synch with remote: %d - %@", last.remoteKey, last.content);
    
    [[WebClient sharedInstance] getLastMessagesForConversation:conversation withLastMessage:last callbackBlock:^(BOOL success, NSArray *messages) {
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
        
//        // all messages, including the new ones
//        __block NSArray *allMessages = nil;
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            for(GLPMessage *message in messages) {
                [GLPMessageDao save:message db:db];
            }
            
            //allMessages = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
        }];
        
        remoteCallback(YES, messages);
    }];
}

+ (void)loadPreviousMessagesBefore:(GLPMessage *)message callback:(void (^)(BOOL success, BOOL remains, NSArray *messages))callback
{
    NSLog(@"load previous messages before %d - %@", message.key, message.content);
    
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
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
                for(GLPMessage *message in messages) {
                    message.isOld = YES;
                    [GLPMessageDao save:message db:db];
                }
            }];
            
            callback(YES, remains, messages);
        }];
    }
}

+ (GLPMessage *)createMessageWithContent:(NSString *)content toConversation:(GLPConversation *)conversation sendCallback:(void (^)(GLPMessage *sentMessage, BOOL success))sendCallback
{
    __block GLPMessage *message = [[GLPMessage alloc] init];
    message.content = content;
    message.conversation = conversation;
    message.date = [NSDate dateInUTC];
    message.author = [SessionManager sharedInstance].user;
    message.sendStatus = kSendStatusLocal;
    message.seen = YES;
    
    conversation.lastUpdate = message.date;
    conversation.lastMessage = message.content;
    
    if(!conversation.isLive) {
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            [GLPMessageDao save:message db:db];
            [GLPConversationDao update:conversation db:db];
        }];
    }
    
    NSLog(@"Post message %@ to server", message.content);
    
    [[WebClient sharedInstance] createMessage:message callbackBlock:^(BOOL responseSuccess, NSInteger remoteKey) {
        NSLog(@"Post to server response: success %d - id %d", responseSuccess, remoteKey);
        
        if(responseSuccess) {
            message.remoteKey = remoteKey;
            message.sendStatus = kSendStatusSent;
        } else {
            message.sendStatus = kSendStatusFailure;
        }
        
        if(!conversation.isLive) {
            [DatabaseManager run:^(FMDatabase *db) {
                [GLPMessageDao update:message db:db];
            }];
        }
        
        sendCallback(message, responseSuccess);
    }];

    return message;
}

// Save message from websocket event
// Executed in background
+ (void)saveMessage:(GLPMessage *)message forConversationRemoteKey:(int)remoteKey
{
    __block GLPConversation *conversation = nil;
    
    // check if the conversation exists in live conversations
    conversation = [[GLPLiveConversationsManager sharedInstance] findByRemoteKey:remoteKey];
    NSLog(@"Conversation is live: %d", conversation != nil);
    
    if(conversation) {
        [ConversationManager saveMessage:message forConversation:conversation];
        return;
    }
    
    // conversation exists in regular conversation
    [DatabaseManager run:^(FMDatabase *db) {
        conversation = [GLPConversationDao findByRemoteKey:remoteKey db:db];
    }];
    NSLog(@"Conversation is normal: %d", conversation != nil);
    
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
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPNewMessage" object:nil userInfo:@{@"message":message}];
    }
}

// Save conversation from websocket event
// Executed in background
+ (void)saveConversation:(GLPConversation *)conversation
{
    DDLogInfo(@"Save conversation with remote key %d", conversation.remoteKey);
    
    if(conversation.isLive) {
        DDLogError(@"Save live conversation, ignore for now");
    } else {
        DDLogInfo(@"Save regular conversation");
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            [GLPConversationDao save:conversation db:db];
        }];
    }
}


@end
