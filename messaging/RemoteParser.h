//
//  RemoteParser.h
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPConversation.h"
#import "GLPMessage.h"
#import "GLPUser.h"
#import "GLPPost.h"
#import "GLPComment.h"

@interface RemoteParser : NSObject

// user
+ (GLPUser *)parseUserFromJson:(NSDictionary *)json;

// conversations
+ (GLPConversation *)parseConversationFromJson:(NSDictionary *)json;
+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations;

// messages
+ (GLPMessage *)parseMessageFromJson:(NSDictionary *)json forConversation:(GLPConversation *)conversation;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(GLPConversation *)conversation;
+ (GLPMessage *)parseMessageFromLongPollJson:(NSDictionary *)json;

// posts and comments
+ (GLPPost *)parsePostFromJson:(NSDictionary *)json;
+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts;
+ (GLPComment *)parseCommentFromJson:(NSDictionary *)json forPost:(GLPPost *)post;
+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments forPost:(GLPPost *)post;

// commons
+ (NSDate *)parseDateFromString:(NSString *)string;

@end
