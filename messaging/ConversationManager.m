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



@implementation ConversationManager

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback
{
    NSLog(@"load conversations");
    
    NSArray *localEntities = [GLPConversationDao findAllOrderByDate];
    localCallback(localEntities);
    NSLog(@"local conversations %d", localEntities.count);
    
    [[WebClient sharedInstance] getConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        [GLPConversationDao replaceAllConversationsWith:conversations];
        remoteCallback(YES, conversations);
        NSLog(@"remote conversations %d", conversations.count);
    }];
}


+ (void)loadMessagesForConversation:(GLPConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback
{
    NSLog(@"load messages for conversation %d", conversation.remoteKey);
    
    NSArray *localEntities = [GLPMessageDao findAllOrderByDateForConversation:conversation];
    localCallback(localEntities);
    NSLog(@"local messages %d", localEntities.count);
    
    GLPMessage *last = [GLPMessageDao findLastRemoteAndSeenForConversation:conversation];
//    for (int i = localEntities.count - 1; i >= 0; i--) {
//        GLPMessage *message = localEntities[i];
//        if(message.remoteKey != 0) {
//            last = message;
//            break;
//        }
//    }
    
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
        
        // all messages, including the new ones
        NSArray *allMessages = [GLPMessageDao findAllOrderByDateForConversation:conversation afterInsertingNewMessages:messages];
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
    
    NSLog(@"message %@ date %@", message.content, message.date);

    message.author = [SessionManager sharedInstance].user;
    message.sendStatus = kSendStatusLocal;
    
    [GLPMessageDao save:message isNew:YES];
    
    NSLog(@"Post message %@ to server", message.content);
    
    [[WebClient sharedInstance] createMessage:message callbackBlock:^(BOOL responseSuccess, NSInteger remoteKey) {
        NSLog(@"Post to server response: success %d - id %d", responseSuccess, remoteKey);
        
        if(responseSuccess) {
            message.remoteKey = remoteKey;
            message.sendStatus = kSendStatusSent;
        } else {
            message.sendStatus = kSendStatusFailure;
        }
        
        [GLPMessageDao update:message];
        sendCallback(message, responseSuccess);
    }];

    return message;
}

//+ (Conversation *)getOrCreateConversationForRemoteKey:(NSInteger)remoteKey
//{
//    Conversation *conversation = [Conversation MR_findFirstByAttribute:@"remoteKey" withValue:[NSNumber numberWithInteger:remoteKey]];
//    
//    
//}

@end
