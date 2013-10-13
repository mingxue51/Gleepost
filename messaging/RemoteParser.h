//
//  RemoteParser.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conversation.h"
#import "Message.h"
#import "User.h"

@interface RemoteParser : NSObject

// user
+ (User *)parseUserFromJson:(NSDictionary *)json;

// conversations
+ (Conversation *)parseConversationFromJson:(NSDictionary *)json;
+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations;

// messages
+ (Message *)parseMessageFromJson:(NSDictionary *)json forConversation:(Conversation *)conversation;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(Conversation *)conversation;

@end
