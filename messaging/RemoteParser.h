//
//  RemoteParser.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conversation.h"
#import "GLPMessage.h"
#import "GLPUser.h"
#import "Post.h"
#import "Comment.h"

@interface RemoteParser : NSObject

// user
+ (GLPUser *)parseUserFromJson:(NSDictionary *)json;

// conversations
+ (Conversation *)parseConversationFromJson:(NSDictionary *)json;
+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations;

// messages
+ (GLPMessage *)parseMessageFromJson:(NSDictionary *)json forConversation:(Conversation *)conversation;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(Conversation *)conversation;

// posts and comments
+ (Post *)parsePostFromJson:(NSDictionary *)json;
+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts;
+ (Comment *)parseCommentFromJson:(NSDictionary *)json forPost:(Post *)post;
+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments forPost:(Post *)post;

// commons
+ (NSDate *)parseDateFromString:(NSString *)string;

@end
