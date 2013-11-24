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
#import "GLPLiveConversationDao.h"
#import "UserManager.h"
#import "SessionManager.h"
#import "WebClient.h"
#import "WebClientHelper.h"
#import "MessagesSendingProcessor.h"
#import "NSDate+UTC.h"
#import "DatabaseManager.h"
#import "GLPConversationParticipantsDao.h"
#import "GLPUserDao.h"
#import "NSNotificationCenter+Utils.h"

@implementation ConversationManager

int const NumberMaxOfMessagesLoaded = 20;

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
    NSArray *localEntities = [ConversationManager getLocalConversations];
    localCallback(localEntities);
    NSLog(@"Load local conversations %d", localEntities.count);
    
    [[WebClient sharedInstance] getConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
        if(!success) {
            remoteCallback(NO, nil);
            return;
        }
        
        //Find the regular conversations.
        
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

//+ (void)loadPreviousMessagesBefore:(GLPMessage *)message callback:(void (^)(BOOL success, BOOL remains, NSArray *messages))callback


+(void)usersWithConversationId:(int)conversationId callback:(void (^)(BOOL success, NSArray *participants))callback
{
    /**
     __block NSArray *localEntities = nil;
     [DatabaseManager run:^(FMDatabase *db) {
     localEntities = [GLPMessageDao findPreviousMessagesBefore:message db:db];
     }];
     */
    
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPConversationParticipantsDao participants:conversationId db:db];
        
        //Fetch users' details.
        
        
        
        callback(YES, localEntities);
    }];
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
        
        GLPLiveConversation *liveConversation = [GLPLiveConversationDao findByRemoteKey:message.conversation.remoteKey db:db];
        
        if(liveConversation) {
            liveConversation.lastUpdate = message.date;
            [GLPLiveConversationDao updateLastUpdate:liveConversation db:db];
        } else {
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
        }
        
        [GLPMessageDao save:message db:db];
        success = YES;
    }];
    
    if(success) {        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:@"GLPNewMessage" object:nil userInfo:@{@"message":message}];
    }
}


@end
