//
//  GLPLiveGroupConversationsManager.h
//  Gleepost
//
//  Created by Silouanos on 11/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  GLPConversation;
@class GLPMessage;

@interface GLPLiveGroupConversationsManager : NSObject

+ (GLPLiveGroupConversationsManager *)sharedInstance;
- (void)loadConversationWithRemoteKey:(NSInteger)conversationRemoteKey;
- (void)loadConversationsWithGroups:(NSArray *)groups;

- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;
- (void)addLocalMessageToConversation:(GLPMessage *)message;
- (void)addRemoteMessage:(GLPMessage *)message toConversationWithRemoteKey:(NSInteger)remoteKey;
- (void)updateLocalMessageAfterSending:(GLPMessage *)message;

- (void)resetLastShownMessageForConversation:(GLPConversation *)detachedConversation;
- (void)syncConversation:(GLPConversation *)detachedConversation;
- (NSArray *)lastestMessagesForConversation:(GLPConversation *)conversation;
- (NSArray *)oldestMessagesForConversation:(GLPConversation *)detachedConversation;
- (void)markConversation:(GLPConversation *)conversation upToTheLastMessageAsRead:(GLPMessage *)lastMessage;
- (NSArray *)loadLatestMessagesForConversation:(GLPConversation *)conversation;
- (void)syncConversationPreviousMessages:(GLPConversation *)detachedConversation;

- (void)clear;

@end
