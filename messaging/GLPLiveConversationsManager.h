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
- (void)loadConversations;
- (NSArray *)conversations;
- (int)conversationsCount;
- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;

// messages
- (NSArray *)messagesForConversation:(GLPConversation *)conversation;
- (void)updateMessageAfterSending:(GLPMessage *)message;
- (void)addNewMessageToConversation:(GLPMessage *)message;

- (void)markAsNotSynchronizedWithRemote;

@end
