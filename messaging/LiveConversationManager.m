//
//  LiveConversationManager.m
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LiveConversationManager.h"
#import "DatabaseManager.h"
#import "GLPMessageDao.h"
#import "WebClient.h"
#import "NSDate+UTC.h"
#import "SessionManager.h"
#import "GLPLiveConversationParticipantsDao.h"

@implementation LiveConversationManager


+ (NSArray *)getLocalConversations
{
    __block NSArray *conversations = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        conversations = [GLPLiveConversationDao findAllOrderByDate:db];
    }];
    
    return conversations;
}

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback
{
    NSLog(@"Load conversations");
    
    NSArray *localEntities = [LiveConversationManager getLocalConversations];
    localCallback(localEntities);
    NSLog(@"Load local conversations %d", localEntities.count);
    
//    [[WebClient sharedInstance] getConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
//        if(!success) {
//            remoteCallback(NO, nil);
//            return;
//        }
    
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//         
//            for(GLPLiveConversation *conversation in conversations)
//            {
//                [GLPLiveConversationDao save:conversation db:db];
//            }
//        }];
    
    
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        NSArray *conversations = [[NSMutableArray alloc] init];
    
        conversations = [GLPLiveConversationDao findAllOrderByDate:db];
    
        remoteCallback(YES, conversations);
        NSLog(@"Load remote conversations %d", conversations.count);
    }];
}


+ (void)loadMessagesForLiveConversation:(GLPLiveConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback
{
    NSLog(@"load messages for conversation %d", conversation.remoteKey);
    
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPMessageDao findLastMessagesForLiveConversation:conversation db:db];
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
    
    [[WebClient sharedInstance] getLastMessagesForLiveConversation:conversation withLastMessage:last callbackBlock:^(BOOL success, NSArray *messages) {
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
            
            allMessages = [GLPMessageDao findLastMessagesForLiveConversation:conversation db:db];
        }];
        
        remoteCallback(YES, allMessages);
        NSLog(@"final messages %d", allMessages.count);
    }];
}

+ (GLPMessage *)createMessageWithContent:(NSString *)content toLiveConversation:(GLPLiveConversation *)conversation sendCallback:(void (^)(GLPMessage *sentMessage, BOOL success))sendCallback
{
    __block GLPMessage *message = [[GLPMessage alloc] init];
    message.content = content;
    message.liveConversation = conversation;
    message.date = [NSDate dateInUTC];
    message.author = [SessionManager sharedInstance].user;
    message.sendStatus = kSendStatusLocal;
    message.seen = YES;
    
    conversation.lastUpdate = message.date;
    //conversation.lastMessage = message.content;
    
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        [GLPMessageDao save:message db:db];
        NSLog(@"update conversion %d %d", conversation.key, conversation.remoteKey);
//        [GLPLiveConversationDao update:conversation db:db];
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

+(void)liveUsersWithLiveConversations:(NSArray*)liveConversations callback:(void (^) (BOOL success, NSArray *liveParticipantsConversations))callback
{
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        
        for(GLPLiveConversation *liveConversation in liveConversations)
        {
            localEntities = [GLPLiveConversationParticipantsDao participants:liveConversation.key db:db];
            
            liveConversation.participants = localEntities;

        }
        
        //Fetch users' details.
        
        
        callback(YES,liveConversations);
    }];
}

+(void)usersWithConversationId:(int)conversationId callback:(void (^)(BOOL success, NSArray *participants))callback
{
    __block NSArray *localEntities = nil;
    [DatabaseManager run:^(FMDatabase *db) {
        localEntities = [GLPLiveConversationParticipantsDao participants:conversationId db:db];
        
        //Fetch users' details.
        
        
        callback(YES, localEntities);
    }];
}

+(void) addLiveConversation:(GLPLiveConversation*)newConversation
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPLiveConversationDao save:newConversation db:db];
        
    }];
}

+(void)removeLiveConversationWithKey:(int)key
{
    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
        
        [GLPLiveConversationDao deleteLiveConversationWithId:key db:db];
    }];
}

//TODO: Needs to add other methods for messages management.

@end
