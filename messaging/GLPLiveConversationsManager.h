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

// conversations
//- (void)loadLocalRegularConversations;
- (void)loadConversations;
- (void)addConversation:(GLPConversation *)conversation;
- (NSArray *)conversationsList;
- (void)conversationsList:(void (^)(NSArray *liveConversations, NSArray *regularConversations))block;
- (void)syncConversation:(GLPConversation *)conversation;
- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;
- (BOOL)isConversationSync:(GLPConversation *)conversation;
- (NSInteger)conversationsCount;
- (NSInteger)liveConversationsCount;
- (NSInteger)regularConversationsCount;

// messages
- (NSArray *)messagesForConversation:(GLPConversation *)conversation;
- (NSArray *)messagesForConversation:(GLPConversation *)conversation startingAfter:(GLPMessage *)after;
- (void)updateMessageAfterSending:(GLPMessage *)message;
- (void)addNewMessageToConversation:(GLPMessage *)message;
- (void)addMessages:(NSArray *)messages toConversation:(GLPConversation *)conversation before:(GLPMessage *)message;

- (void)markAsNotSynchronizedWithRemote;

@end
