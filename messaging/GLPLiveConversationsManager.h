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

- (void)markAsNotSynchronizedWithRemote;




- (void)loadConversationWithCallback:(void (^)(BOOL success, NSArray *conversations))callback;
- (void)updateConversation:(GLPConversation *)conversation;

@end
