//
//  RemoteParser.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteConversation.h"
#import "RemoteMessage.h"
#import "RemoteUser.h"

@interface RemoteParser : NSObject

// user
+ (RemoteUser *)parseUserFromJson:(NSDictionary *)json;

// conversations
+ (RemoteConversation *)parseConversationFromJson:(NSDictionary *)json;
+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations;

// messages
+ (RemoteMessage *)parseMessageFromJson:(NSDictionary *)json forConversation:(RemoteConversation *)conversation;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(RemoteConversation *)conversation;

@end
