//
//  ConversationManager.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ConversationManager.h"



#import "GLPConversationDao.h"
#import "GLPMessageDao.h"
#import "UserManager.h"
#import "SessionManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "MessagesSendingProcessor.h"
#import "NSDate+UTC.h"
#import "DatabaseManager.h"
#import "GLPConversationParticipantsDao.h"
#import "GLPUserDao.h"

@implementation ConversationManager

+ (NSArray *)getLocalConversations
{
    __block NSArray *conversations = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        conversations = [GLPConversationDao findAllOrderByDate:db];
    }];
    
    return conversations;
}

+(GLPUser* )loadUserWithMessageId: (int)messageId
{
    __block GLPUser* currentUser = nil;
    
    [DatabaseManager run:^(FMDatabase *db) {
        currentUser = [GLPMessageDao findUserByMessageKey:messageId db:db];
    }];
    
    return currentUser;
    
}

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback
{
    NSLog(@"Load conversations");
    
    NSArray *localEntities = [ConversationManager getLocalConversations];
    localCallback(localEntities);
    NSLog(@"Load local conversations %d", localEntities.count);
    
    [[WebClient sharedInstance] getConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            [GLPConversationDao deleteAll:db];
            //Added.
            [GLPConversationParticipantsDao deleteAll:db];
            for(GLPConversation *conversation in conversations)
            {
                [GLPConversationDao save:conversation db:db];
            }
        }];
        
        remoteCallback(YES, conversations);
        NSLog(@"Load remote conversations %d", conversations.count);
    }];
}

+ (void)markConversationRead:(GLPConversation *)conversation
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        conversation.hasUnreadMessages = NO;
        [GLPConversationDao updateUnread:conversation db:db];
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
        
        // update only if new changes from API
        if(!messages || messages.count == 0) {
            remoteCallback(YES, nil);
            return;
        }
        
        NSLog(@"new remote messages %d", messages.count);
        
        // reverse order
        messages = [[messages reverseObjectEnumerator] allObjects];
        
        // all messages, including the new ones
        __block NSArray *allMessages = nil;
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            for(GLPMessage *message in messages) {
                [GLPMessageDao save:message db:db];
            }
            
            allMessages = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
        }];
        
        remoteCallback(YES, allMessages);
        NSLog(@"final messages %d", allMessages.count);
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
        callback(YES, NO, localEntities);
        return;
    }
    
    // load more from web
    if(localEntities.count < 15) {
        [[WebClient sharedInstance] getPreviousMessagesBefore:message callbackBlock:^(BOOL success, NSArray *messages) {
            
            if(!success) {
                callback(NO, NO, nil);
                return;
            }
            
            NSLog(@"previous messages from web %d", messages.count);
            BOOL remains = messages.count == 20;
            
            // reverse order
            messages = [[messages reverseObjectEnumerator] allObjects];
            
            callback(YES, remains, messages);
        }];
    }
    
    
//    
//    GLPMessage *last = nil;
//    for (int i = localEntities.count - 1; i >= 0; i--) {
//        GLPMessage *message = localEntities[i];
//        if(message.remoteKey != 0) {
//            last = message;
//            break;
//        }
//    }
//    
//    NSLog(@"last local message synch with remote: %d - %@", last.remoteKey, last.content);
//    
//    [[WebClient sharedInstance] getLastMessagesForConversation:conversation withLastMessage:last callbackBlock:^(BOOL success, NSArray *messages) {
//        if(!success) {
//            remoteCallback(NO, nil);
//            return;
//        }
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
//        // all messages, including the new ones
//        __block NSArray *allMessages = nil;
//        
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            for(GLPMessage *message in messages) {
//                [GLPMessageDao save:message db:db];
//            }
//            
//            allMessages = [GLPMessageDao findLastMessagesForConversation:conversation db:db];
//        }];
//        
//        remoteCallback(YES, allMessages);
//        NSLog(@"final messages %d", allMessages.count);
//    }];
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
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPMessageDao save:message db:db];
        NSLog(@"update conversion %d %d", conversation.key, conversation.remoteKey);
        [GLPConversationDao update:conversation db:db];
    }];
    
    NSLog(@"Post message %@ to server", message.content);
    
    [[WebClient sharedInstance] createMessage:message callbackBlock:^(BOOL responseSuccess, NSInteger remoteKey) {
        NSLog(@"Post to server response: success %d - id %d", responseSuccess, remoteKey);
        
        if(responseSuccess) {
            message.remoteKey = remoteKey;
            message.sendStatus = kSendStatusSent;
        } else {
            message.sendStatus = kSendStatusFailure;
        }
        
        [DatabaseManager run:^(FMDatabase *db) {
            [GLPMessageDao update:message db:db];
        }];
        
        sendCallback(message, responseSuccess);
    }];

    return message;
}

+(GLPUser* )userWithConversationId:(int)conversationId
{
    __block GLPUser *user;
    //Get user id.
    [DatabaseManager run:^(FMDatabase *db) {
        
        int userKey;
        userKey = [GLPConversationParticipantsDao findByConversationKey:conversationId db:db];
        //Find user's details.
        user = [GLPUserDao findByKey:userKey db:db];

    }];
    
    
    return user;

}

+ (void)saveMessageFromLongpoll:(GLPMessage *)message
{
    __block BOOL success = NO;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {

        // check message not already exists = long poll own message
        GLPMessage *existingMessage = [GLPMessageDao findByRemoteKey:message.remoteKey db:db];
        if(existingMessage) {
            NSLog(@"Insert message that already exists with the remote key %d : %@", message.remoteKey, message.content);
            return;
        }
        
        GLPConversation *conversation = [GLPConversationDao findByRemoteKey:message.conversation.remoteKey db:db];
        
        if(!conversation) {
            conversation = message.conversation;
        }
        
        conversation.lastMessage = message.content;
        conversation.lastUpdate = message.date;
        conversation.hasUnreadMessages = YES;

        if(conversation.key == 0) {
            [GLPConversationDao save:conversation db:db];
        } else {
            [GLPConversationDao update:conversation db:db];
        }
        
        [GLPMessageDao save:message db:db];
        success = YES;
    }];
    
    if(success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPNewMessage" object:nil userInfo:@{@"message":message}];
    }
}

@end
