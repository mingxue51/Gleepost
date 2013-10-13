//
//  ConversationManager.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "Conversation.h"

@interface ConversationManager : NSObject

+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback;
+ (void)loadMessagesForConversation:(Conversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback;
+ (Message *)createMessageWithContent:(NSString *)content toConversation:(Conversation *)conversation sendCallback:(void (^)(Message *sentMessage, BOOL success))sendCallback;
@end
