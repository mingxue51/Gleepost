//
//  JsonParser.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Post.h"
#import "Comment.h"
#import "Conversation.h"
#import "Message.h"

@interface JsonParser : NSObject

+ (User *)parseUserFromJson:(NSDictionary *)json;
+ (Post *)parsePostFromJson:(NSDictionary *)json;
+ (NSArray *)parsePostsFromJson:(NSDictionary *)json;
+ (Comment *)parseCommentFromJson:(NSDictionary *)json;
+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments;

+ (Conversation *)parseConversationFromJson:(NSDictionary *)json ignoringUser:(User *)userToIgnore;
+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations ignoringUser:(User *)userToIgnore;
+ (Message *)parseMessageFromJson:(NSDictionary *)json;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages;
    
@end
