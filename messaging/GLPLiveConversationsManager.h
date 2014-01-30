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

+ (GLPLiveConversationsManager *)sharedInstance;

// conversations
- (void)loadLocalRegularConversations;
- (void)loadConversations;
- (void)addConversation:(GLPConversation *)conversation;
- (NSArray *)conversationsList;
- (void)conversationsList:(void (^)(NSArray *liveConversations, NSArray *regularConversations))block;
- (NSInteger)conversationsCount;
- (NSInteger)liveConversationsCount;
- (NSInteger)regularConversationsCount;
- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;

// messages
- (NSArray *)messagesForConversation:(GLPConversation *)conversation;
- (void)updateMessageAfterSending:(GLPMessage *)message;
- (void)addNewMessageToConversation:(GLPMessage *)message;
- (void)addMessages:(NSArray *)messages toConversation:(GLPConversation *)conversation before:(GLPMessage *)message;

- (void)markAsNotSynchronizedWithRemote;

@end
