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
- (void)addConversation:(GLPConversation *)conversation;
- (NSArray *)conversationsList;
- (void)conversationsList:(void (^)(NSArray *liveConversations, NSArray *regularConversations))block;
- (void)syncConversation:(GLPConversation *)conversation;
- (void)resetLastShownMessageForConversation:(GLPConversation *)conversation;
- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;
//- (BOOL)isConversationSync:(GLPConversation *)conversation;
- (NSInteger)conversationsCount;
- (NSInteger)liveConversationsCount;
- (NSInteger)regularConversationsCount;

// messages
- (NSArray *)lastestMessagesForConversation:(GLPConversation *)conversation;
- (NSArray *)messagesForConversation:(GLPConversation *)conversation;
- (NSArray *)messagesForConversation:(GLPConversation *)conversation startingAfter:(GLPMessage *)after;
- (void)updateLocalMessageAfterSending:(GLPMessage *)message;
- (void)addLocalMessageToConversation:(GLPMessage *)message;
- (void)addRemoteMessage:(GLPMessage *)message toConversationWithRemoteKey:(NSInteger)remoteKey;
- (void)addMessages:(NSArray *)messages toConversation:(GLPConversation *)conversation before:(GLPMessage *)message;

- (void)markNotSynchronized;

@end
