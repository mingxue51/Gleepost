//
//  ConversationManager.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GLPConversation.h"
#import "GLPMessage.h"
#import "GLPUser.h"

@interface ConversationManager : NSObject

extern int const NumberMaxOfMessagesLoaded;

+ (NSArray *)getLocalNormalConversations;
+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback;
+ (void)loadLiveConversationsWithCallback:(void (^)(BOOL success, NSArray *conversations))callback;
+ (void)markConversationRead:(GLPConversation *)conversation;

+ (NSArray *)loadMessagesForConversation:(GLPConversation *)conversation;
+ (NSArray *)loadPreviousMessagesForConversation:(GLPConversation *)conversation;
+ (void)loadMessagesForConversation:(GLPConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback;
+ (void)loadPreviousMessagesBefore:(GLPMessage *)message callback:(void (^)(BOOL success, BOOL remains, NSArray *messages))callback;

+ (void)createMessageWithContent:(NSString *)content toConversation:(GLPConversation *)conversation localCallback:(void (^)(GLPMessage *localMessage))localCallback sendCallback:(void (^)(GLPMessage *sentMessage, BOOL success))sendCallback;

+ (void)saveMessage:(GLPMessage *)message forConversationRemoteKey:(int)remoteKey;
+ (void)saveMessage:(GLPMessage *)message forConversation:(GLPConversation *)conversation;
+ (void)sendMessage:(GLPMessage *)message;

+ (void)saveConversation:(GLPConversation *)conversation;

@end
