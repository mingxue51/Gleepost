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
#import "GLPContact.h"
#import "GLPNotification.h"
#import "GLPWebSocketEvent.h"

@interface RemoteParser : NSObject

// user
+ (GLPUser *)parseUserFromJson:(NSDictionary *)json;

// conversations
+ (GLPConversation *)parseConversationFromJson:(NSDictionary *)json;
+ (NSArray *)parseConversationsFilterByLive:(BOOL)live fromJson:(NSArray *)jsonConversations;
+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations;
//+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations;
//+ (NSArray *)parseLiveConversationsFromJson:(NSArray *)jsonConversations;
+(NSArray*)orderAndGetLastThreeConversations:(NSArray*)liveConversations;

// messages
+ (GLPMessage *)parseMessageFromJson:(NSDictionary *)json forConversation:(GLPConversation *)conversation;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(GLPConversation *)conversation;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forLiveConversation:(GLPLiveConversation *)conversation;
+ (GLPMessage *)parseMessageFromLongPollJson:(NSDictionary *)json;

// posts and comments
+ (GLPPost *)parsePostFromJson:(NSDictionary *)json;
+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts;
+ (GLPComment *)parseCommentFromJson:(NSDictionary *)json forPost:(GLPPost *)post;
+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments forPost:(GLPPost *)post;
+(GLPPost*)parseIndividualPostFromJson:(NSDictionary*)json;
+(NSString*)parseCategoriesToTags:(NSArray*)categories;

// contacts
+ (NSArray*)parseContactsFromJson:(NSArray *)jsonContacts;

// commons
+ (NSDate *)parseDateFromString:(NSString *)string;

+(NSString*)parseRegisterErrorMessage:(NSString*)error;

// images
+(NSString*)parseImageUrl:(NSDictionary*)url;
+(int)parseIdFromJson:(NSDictionary*)json;

// notifications
+ (GLPNotification *)parseNotificationFromJson:(NSDictionary *)json;
+ (NSArray *)parseNotificationsFromJson:(NSArray *)jsonConversations;

// web socket event
+ (GLPWebSocketEvent *)parseWebSocketEventFromJson:(NSDictionary *)json;

+(BOOL)parseBusyStatus:(NSDictionary*)json;

// invite message
+ (NSString *)parseMessageFromJson:(NSDictionary *)json;

@end
