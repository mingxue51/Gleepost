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

+ (void)loadMessagesForConversation:(GLPConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback;
+ (void)loadPreviousMessagesBefore:(GLPMessage *)message callback:(void (^)(BOOL success, BOOL remains, NSArray *messages))callback;

+ (GLPMessage *)createMessageWithContent:(NSString *)content toConversation:(GLPConversation *)conversation sendCallback:(void (^)(GLPMessage *sentMessage, BOOL success))sendCallback;
+ (void)saveMessageFromLongpoll:(GLPMessage *)message;

@end
