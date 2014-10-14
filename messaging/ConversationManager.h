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

// new methods
+ (NSArray *)loadLocalRegularConversations;
+ (void)saveOrUpdateConversation:(GLPConversation *)conversation;
+ (void)initialSaveConversationsToDatabase:(NSArray *)conversations;
+ (void)deleteConversation:(GLPConversation *)conversation;
+ (void)initialSaveMessagesToDatabase:(NSArray *)messages;
+ (NSArray *)loadLatestMessagesForConversation:(GLPConversation *)conversation;;
+ (void)saveNewMessage:(GLPMessage *)message withConversation:(GLPConversation *)conversation;

// old methods
+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback;
+ (void)loadLiveConversationsWithCallback:(void (^)(BOOL success, NSArray *conversations))callback;
+ (void)markConversationRead:(GLPConversation *)conversation;
+(void)loadConversationWithParticipant:(int)remoteKey withCallback:(void (^) (BOOL sucess, GLPConversation* conversation))callback;

// messages
//+ (NSArray *)loadMessagesForConversation:(GLPConversation *)conversation;
+ (void)loadPreviousMessagesForConversation:(GLPConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback;
+ (void)loadPreviousMessagesForConversation:(GLPConversation *)conversation before:(GLPMessage *)message localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback;


+ (void)loadMessagesForConversation:(GLPConversation *)conversation localCallback:(void (^)(NSArray *messages, BOOL isFinal))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback;
+ (void)loadPreviousMessagesBefore:(GLPMessage *)message callback:(void (^)(BOOL success, BOOL remains, NSArray *messages))callback;

+ (void)createMessageWithContent:(NSString *)content toConversation:(GLPConversation *)conversation;

//+ (void)saveMessageFromWebsocket:(GLPMessage *)message forConversationRemoteKey:(int)remoteKey;
+ (void)saveMessage:(GLPMessage *)message forConversationRemoteKey:(int)remoteKey;
+ (void)saveMessage:(GLPMessage *)message forConversation:(GLPConversation *)conversation;
+ (void)sendMessage:(GLPMessage *)message;

+ (void)saveConversation:(GLPConversation *)conversation;
+(void)saveConversationIfNotExist:(GLPConversation *)conversation;

+(GLPConversation*)createFakeConversationWithParticipants:(NSArray*)participants;

@end
