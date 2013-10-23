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



@implementation ConversationManager

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback
{
    NSLog(@"Load conversations");
    
    [DatabaseManager run:^(FMDatabase *db) {
        NSArray *localEntities = [GLPConversationDao findAllOrderByDate:db];
        localCallback(localEntities);
        NSLog(@"Load local conversations %d", localEntities.count);
    }];
    
    [[WebClient sharedInstance] getConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
            [GLPConversationDao deleteAll:db];
            for(GLPConversation *conversation in conversations) {
                [GLPConversationDao save:conversation db:db];
            }
        }];
        
        remoteCallback(YES, conversations);
        NSLog(@"Load remote conversations %d", conversations.count);
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

+ (GLPMessage *)createMessageWithContent:(NSString *)content toConversation:(GLPConversation *)conversation sendCallback:(void (^)(GLPMessage *sentMessage, BOOL success))sendCallback
{
    __block GLPMessage *message = [[GLPMessage alloc] init];
    message.content = content;
    message.conversation = conversation;
    message.date = [NSDate dateInUTC];
    message.author = [SessionManager sharedInstance].user;
    message.sendStatus = kSendStatusLocal;
    message.seen = YES;
    
    [DatabaseManager run:^(FMDatabase *db) {
        [GLPMessageDao save:message db:db];
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
        
        GLPConversation *existingConversation = [GLPConversationDao findByRemoteKey:message.conversation.remoteKey db:db];
        
        if(existingConversation) {
            message.conversation = existingConversation;
            NSLog(@"existing conversation %d", existingConversation.remoteKey);
        } else {
            [GLPConversationDao save:message.conversation db:db];
            //TODO: check works properly
        }
        
        [GLPMessageDao save:message db:db];
        success = YES;
    }];
    
    if(success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GLPNewMessage" object:nil userInfo:@{@"message":message}];
    }
}

@end
