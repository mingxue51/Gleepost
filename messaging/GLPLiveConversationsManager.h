//
//  GLPLiveConversationsManager.h
//  Gleepost
//
//  Created by Lukas on 11/27/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPConversation.h"

@interface GLPLiveConversationsManager : NSObject

@property (assign, nonatomic, readonly) BOOL areConversationsSync;

+ (GLPLiveConversationsManager *)sharedInstance;

- (void)clear;

// conversations
- (void)loadConversations;
- (void)createRandomConversation:(void (^)(GLPConversation *conversation))callback;
- (void)createRegularConversationWithUser:(GLPUser *)user callback:(void (^)(GLPConversation *conversation))callback;
- (void)createRegularConversationWithUsers:(NSArray *)users callback:(void (^)(GLPConversation *))callback;
- (void)addConversation:(GLPConversation *)conversation;
- (void)endConversation:(GLPConversation *)conversation;
- (void)randomToRegular:(GLPConversation *)detachedRegularConversation;
- (NSArray *)conversationsList;
- (void)conversationsList:(void (^)(NSArray *liveConversations, NSArray *regularConversations))block;
- (void)syncConversation:(GLPConversation *)conversation;
- (void)syncConversationPreviousMessages:(GLPConversation *)detachedConversation;
- (void)resetLastShownMessageForConversation:(GLPConversation *)conversation;
- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;
- (GLPConversation *)findRegularByParticipant:(GLPUser *)participant;
- (GLPConversation *)findOneToOneConversationWithParticipant:(GLPUser *)participant;
- (GLPConversation *)findGroupConversationWithParticipants:(NSArray *)users;
- (void)deleteConversation:(GLPConversation *)conversation withCallbackBlock:(void (^) (BOOL success))callback;
- (BOOL)conversationCanHavePreviousMessages:(GLPConversation *)conversation;
- (GLPConversation *)oldestLiveConversation;
- (NSInteger)conversationsCount;
- (NSInteger)liveConversationsCount;
- (NSInteger)regularConversationsCount;

// messages
- (NSArray *)lastestMessagesForConversation:(GLPConversation *)conversation;
- (NSArray *)oldestMessagesForConversation:(GLPConversation *)detachedConversation;
- (NSArray *)messagesForConversation:(GLPConversation *)conversation;
- (NSArray *)messagesForConversation:(GLPConversation *)conversation startingAfter:(GLPMessage *)after;
- (void)updateLocalMessageAfterSending:(GLPMessage *)message;
- (void)addLocalMessageToConversation:(GLPMessage *)message;
- (void)addRemoteMessage:(GLPMessage *)message toConversationWithRemoteKey:(NSInteger)remoteKey;
- (void)addMessages:(NSArray *)messages toConversation:(GLPConversation *)conversation before:(GLPMessage *)message;
- (void)markConversation:(GLPConversation *)conversation upToTheLastMessageAsRead:(GLPMessage *)lastMessage;

- (void)markNotSynchronized;

@end
