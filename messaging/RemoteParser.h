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
#import "GLPGroup.h"

@interface RemoteParser : NSObject

// user
+ (GLPUser *)parseUserFromJson:(NSDictionary *)json;
+ (NSArray *)parseUsersFromJson:(NSArray *)jsonArray;
+ (NSArray *)parseAttendeesFromJson:(NSDictionary *)jsonDictionary;
+ (NSString *)generateServerUserNameTypeWithNameSurname:(NSString *)nameSurname;

// pending posts
+ (NSArray *)parsePendingPostsFromJson:(NSArray *)jsonPosts;

// approval
+ (NSInteger)parseApprovalLevel:(NSDictionary *)approvalLevel;

// conversations
+ (GLPConversation *)parseConversationFromJson:(NSDictionary *)json;
+ (NSArray *)parseConversationsFilterByLive:(BOOL)live fromJson:(NSArray *)jsonConversations;
+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations;
//+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations;
//+ (NSArray *)parseLiveConversationsFromJson:(NSArray *)jsonConversations;
+(NSArray*)orderAndGetLastThreeConversations:(NSArray*)liveConversations;
+ (NSString *)generateParticipandsUserIdFormat:(NSArray *)users;

// messages
+ (GLPMessage *)parseMessageFromJson:(NSDictionary *)json forConversation:(GLPConversation *)conversation;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(GLPConversation *)conversation;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forLiveConversation:(GLPLiveConversation *)conversation;
+ (GLPMessage *)parseMessageFromLongPollJson:(NSDictionary *)json;

// posts and comments
+ (GLPPost *)parsePostFromJson:(NSDictionary *)json;
+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts;
+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts withGroupRemoteKey:(NSInteger)groupRemoteKey;
+ (GLPComment *)parseCommentFromJson:(NSDictionary *)json forPost:(GLPPost *)post;
+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments forPost:(GLPPost *)post;
+(NSString*)parseCategoriesToTags:(NSArray*)categories;
+(NSArray *)parseLivePostsIds:(NSArray *)jsonIds;

// attendees

+(NSInteger)parseNewPopularity:(NSDictionary *)json;

// groups
+ (GLPGroup *)parseGroupFromJson:(NSDictionary *)json;
+ (NSArray *)parseGroupsFromJson:(NSArray *)json;
+ (NSArray *)parsePostsGroupFromJson:(NSArray *)jsonPosts;

+ (NSArray *)parseMembersFromJson:(NSArray *)jsonArray withGroupRemoteKey:(int)groupRemoteKey;

// contacts
+ (NSArray*)parseContactsFromJson:(NSArray *)jsonContacts;

// commons
+ (NSDate *)parseDateFromString:(NSString *)string;

+(NSString*)parseRegisterErrorMessage:(NSString*)error;
+(NSString*)parseLoginErrorMessage:(NSString*)error;
+ (NSString *)parseFBRegisterErrorMessage:(NSString *)error;
+(NSString *)parseLoadingGroupErrorMessage:(NSString *)error;

// images
+(NSString*)parseImageUrl:(NSDictionary*)url;
+(int)parseIdFromJson:(NSDictionary*)json;

// videos
+ (NSNumber *)parseVideoResponse:(id)responseObject;
+ (GLPVideo *)parseVideoData:(NSDictionary *)videoData;

// notifications
+ (GLPNotification *)parseNotificationFromJson:(NSDictionary *)json;
+ (NSArray *)parseNotificationsFromJson:(NSArray *)jsonConversations;

// web socket event
+ (GLPWebSocketEvent *)parseWebSocketEventFromJson:(NSDictionary *)json;

+(BOOL)parseBusyStatus:(NSDictionary*)json;

// invite message
+ (NSString *)parseMessageFromJson:(NSDictionary *)json;

// foursquare
+ (NSArray *)parseNearbyVenuesWithResponseObject:(id)responseObject;
+ (NSArray *)parseNearbyVenuesWithResponseLocationsObject:(id)responseObject;

// facebook
+(BOOL)isAccountVerified:(NSDictionary *)json;
+(BOOL)isAccountRegistered:(NSDictionary *)json;
+(NSString *)parseFBStatusFromAPI:(NSDictionary *)json;


@end
