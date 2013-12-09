// //
////  LiveConversationManager.m
////  Gleepost
////
////  Created by Σιλουανός on 28/10/13.
////  Copyright (c) 2013 Gleepost. All rights reserved.
////
//
//#import "LiveConversationManager.h"
//#import "DatabaseManager.h"
//#import "GLPMessageDao.h"
//#import "WebClient.h"
//#import "NSDate+UTC.h"
//#import "SessionManager.h"
//#import "GLPLiveConversationParticipantsDao.h"
//
//@implementation LiveConversationManager
//
//
//+ (NSArray *)getLocalConversations
//{
//    __block NSArray *conversations = nil;
//    [DatabaseManager run:^(FMDatabase *db) {
//        conversations = [GLPLiveConversationDao findAllOrderByExpiry:db];
//    }];
//    
//    return conversations;
//}
//
//+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, BOOL newConversations, NSArray *conversations))remoteCallback
//{
//    NSArray *localEntities = [LiveConversationManager getLocalConversations];
//    localCallback(localEntities);
//    
//    
//    [[WebClient sharedInstance] getLiveConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
//        
//        if(!success) {
//            remoteCallback(NO, NO ,nil);
//            return;
//        }
//
//        [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//            
//                [GLPLiveConversationDao deleteAll:db];
//                
//                for(GLPLiveConversation *conversation in conversations)
//                {
//                    [GLPLiveConversationDao save:conversation db:db];
//                }
//        }];
//        
//        remoteCallback(YES, YES, conversations);
//    }];
//    
//}
//
//
///**
// //OLD CODE.
// 
// 
// 
//
//
//+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, BOOL newConversations ,NSArray *conversations))remoteCallback
//{
//    NSLog(@"Load conversations");
//    
//    NSArray *localEntities = [LiveConversationManager getLocalConversations];
//    localCallback(localEntities);
//    NSLog(@"Load local conversations %d", localEntities.count);
//    
//    [[WebClient sharedInstance] getLiveConversationsWithCallbackBlock:^(BOOL success, NSArray *conversations) {
//        
//        if(!success) {
//            remoteCallback(NO, NO ,nil);
//            return;
//        }
//        
//        NSLog(@"Local entities: %@",localEntities);
//        NSArray *newConversations = [[NSArray alloc]init];
//        
//        if(localEntities.count != 0)
//        {
//            newConversations = [LiveConversationManager getNewConversationsWithCurrent:localEntities andNew:conversations];
//        }
//        else
//        {
//            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//                
//                for(GLPLiveConversation *conversation in conversations)
//                {
//                    [GLPLiveConversationDao save:conversation db:db];
//                }
//            }];
//            
//            remoteCallback(YES, NO, newConversations);
//            
//        }
//        
//        
//        if(newConversations.count == 0)
//        {
//            //Don't do anything.
//            remoteCallback(YES, NO, newConversations);
//            
//        }
//        else
//        {
//            //Delete old conversations and add the new to the database.
//            
//            [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//                
//                
//                //Delete old conversations.
//                
//                
//                for(int i = 0; i<newConversations.count; ++i)
//                {
//                    GLPLiveConversation *liveConversation = [localEntities objectAtIndex:i];
//                    
//                    [LiveConversationManager removeLiveConversationWithKey:liveConversation.key];
//                }
//                
//                //Add new conversations.
//                
//                for(GLPLiveConversation *conv in newConversations)
//                {
//                    [GLPLiveConversationDao save:conv db:db];
//                }
//                
//                remoteCallback(YES, YES, newConversations);
//                
//                
//                //                [GLPLiveConversationDao deleteAll:db];
//                //
//                //                for(GLPLiveConversation *conversation in conversations)
//                //                {
//                //                    [GLPLiveConversationDao save:conversation db:db];
//                //                }
//            }];
//        }
//        
//        
//        
//        
//        
//    }];
//    
//    //remoteCallback(YES, localEntities);
//    
//    
//    //    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//    //        NSArray *conversations = [[NSMutableArray alloc] init];
//    //    
//    //        conversations = [GLPLiveConversationDao findAllOrderByDate:db];
//    
//    
//    //    }];
//}
// 
//*/
//
//+(NSArray*)getNewConversationsWithCurrent:(NSArray*) currentConversations andNew:(NSArray*)serverConversations
//{
//    NSMutableArray *newConversations = [[NSMutableArray alloc] init];
//    
//    for(int i = 0; i<serverConversations.count; ++i)
//    {
//        GLPLiveConversation *newConv = [serverConversations objectAtIndex:i];
//        GLPLiveConversation *currentConv = [currentConversations objectAtIndex:i];
//        
//        if([[[newConv.participants objectAtIndex:1] name] isEqualToString:[[currentConv.participants objectAtIndex:0] name]])
//        {
//            
//        }
//        else
//        {
//            [newConversations addObject:newConv];
//        }
//    }
//    
//    NSLog(@"getNewConversationsWithCurrent");
//    
//    
//    return newConversations;
//}
//
//
//+ (void)loadMessagesForLiveConversation:(GLPLiveConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback
//{
//    NSLog(@"load messages for conversation %d", conversation.remoteKey);
//    
//    __block NSArray *localEntities = nil;
//    [DatabaseManager run:^(FMDatabase *db) {
//        localEntities = [GLPMessageDao findLastMessagesForLiveConversation:conversation db:db];
//    }];
//    
//    localCallback(localEntities);
//    NSLog(@"local messages %d", localEntities.count);
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
//    [[WebClient sharedInstance] getLastMessagesForLiveConversation:conversation withLastMessage:last callbackBlock:^(BOOL success, NSArray *messages) {
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
//            allMessages = [GLPMessageDao findLastMessagesForLiveConversation:conversation db:db];
//        }];
//        
//        remoteCallback(YES, allMessages);
//        NSLog(@"final messages %d", allMessages.count);
//    }];
//}
//
//+ (GLPMessage *)createMessageWithContent:(NSString *)content toLiveConversation:(GLPLiveConversation *)conversation sendCallback:(void (^)(GLPMessage *sentMessage, BOOL success))sendCallback
//{
//    __block GLPMessage *message = [[GLPMessage alloc] init];
//    message.content = content;
//    message.liveConversation = conversation;
//    message.date = [NSDate dateInUTC];
//    message.author = [SessionManager sharedInstance].user;
//    message.sendStatus = kSendStatusLocal;
//    message.seen = YES;
//    
//    conversation.lastUpdate = message.date;
//    
//    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//        [GLPMessageDao save:message db:db];
//        [GLPLiveConversationDao updateLastUpdate:conversation db:db];
//    }];
//    
//    NSLog(@"Post message %@ to server", message.content);
//    
//    [[WebClient sharedInstance] createMessage:message callbackBlock:^(BOOL responseSuccess, NSInteger remoteKey) {
//        NSLog(@"Post to server response: success %d - id %d", responseSuccess, remoteKey);
//        
//        if(responseSuccess) {
//            message.remoteKey = remoteKey;
//            message.sendStatus = kSendStatusSent;
//        } else {
//            message.sendStatus = kSendStatusFailure;
//        }
//        
//        [DatabaseManager run:^(FMDatabase *db) {
//            [GLPMessageDao update:message db:db];
//        }];
//        
//        sendCallback(message, responseSuccess);
//    }];
//    
//    return message;
//}
//
//+(void)liveUsersWithLiveConversations:(NSArray*)liveConversations callback:(void (^) (BOOL success, NSArray *liveParticipantsConversations))callback
//{
//    __block NSArray *localEntities = nil;
//    [DatabaseManager run:^(FMDatabase *db) {
//        
//        for(GLPLiveConversation *liveConversation in liveConversations)
//        {
//            localEntities = [GLPLiveConversationParticipantsDao participants:liveConversation.key db:db];
//            
//            liveConversation.participants = localEntities;
//            
//            NSAssert(localEntities.count!=0, @"A conversation needs participant.");
//
//        }
//        
//        //Fetch users' details.
//        
//        
//        callback(YES,liveConversations);
//    }];
//}
//
//+(void)usersWithConversationId:(int)conversationId callback:(void (^)(BOOL success, NSArray *participants))callback
//{
//    __block NSArray *localEntities = nil;
//    [DatabaseManager run:^(FMDatabase *db) {
//        localEntities = [GLPLiveConversationParticipantsDao participants:conversationId db:db];
//        
//        //Fetch users' details.
//        
//        
//        callback(YES, localEntities);
//    }];
//}
//
//+(void) addLiveConversation:(GLPLiveConversation*)newConversation
//{
//    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//        
//        [GLPLiveConversationDao save:newConversation db:db];
//        
//    }];
//}
//
//+(void)removeLiveConversationWithKey:(int)key
//{
//    [DatabaseManager transaction:^(FMDatabase *db, BOOL *rollback) {
//        
//        BOOL success = [GLPLiveConversationDao deleteLiveConversationWithId:key db:db];
//        
//        NSLog(@"REMOVED LIVE: %d",success);
//    }];
//}
//
////TODO: Needs to add other methods for messages management.
//
//@end
