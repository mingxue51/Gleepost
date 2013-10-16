////
////  JsonParser.m
////  messaging
////
////  Created by Lukas on 8/28/13.
////  Copyright (c) 2013 Gleepost. All rights reserved.
////
//
//#import "JsonParser.h"
//#import "DateFormatterManager.h"
//
//@implementation JsonParser
//
////+ (OldUser *)parseUserFromJson:(NSDictionary *)json
////{
////    OldUser *user = [[OldUser alloc] init];
////    user.key = [json[@"id"] integerValue];
////    user.name = json[@"username"];
////    
////    // optional
////    user.tagline = json[@"tagline"];
////    user.profileImageUrl = json[@"profile_image"];
////    user.course = json[@"course"];
////    
////    if(json[@"network"]) {
////        user.network = json[@"network"];
////    }
////    
////    return user;
////}
//
//+ (UserNetwork *)parseUserNetworkFromJson:(NSDictionary *)json;
//{
//    UserNetwork *userNetwork = [[UserNetwork alloc] init];
//    userNetwork.key = [json[@"id"] integerValue];
//    userNetwork.name = json[@"name"];
//    
//    return userNetwork;
//}
//
//+ (Post *)parsePostFromJson:(NSDictionary *)json
//{
//    Post *post = [[Post alloc] init];
//    post.key = [json[@"id"] integerValue];
////    post.user = [JsonParser parseUserFromJson:json[@"by"]];
//    post.date = [[DateFormatterManager sharedInstance].fullDateFormatter dateFromString:json[@"timestamp"]];
//    post.content = json[@"text"];
//    post.commentsCount = [json[@"comments"] integerValue];
//    post.socialContent.likes = [json[@"likes"] integerValue];
//    post.socialContent.hates = [json[@"hates"] integerValue];
//    
//    return post;
//}
//
//+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts
//{
//    NSMutableArray *posts = [NSMutableArray array];
//    for(id postJson in jsonPosts) {
//        Post *post = [JsonParser parsePostFromJson:postJson];
//        [posts addObject:post];
//    }
//    
//    return posts;
//}
//
//+ (Comment *)parseCommentFromJson:(NSDictionary *)json
//{
//    Comment *comment = [[Comment alloc] init];
//    comment.key = [json[@"id"] integerValue];
////    comment.user = [JsonParser parseUserFromJson:json[@"by"]];
//    comment.date = [[DateFormatterManager sharedInstance].fullDateFormatter dateFromString:json[@"timestamp"]];
//    comment.content = json[@"text"];
//    
//    return comment;
//}
//
//+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments
//{
//    NSMutableArray *comments = [NSMutableArray array];
//    for(id jsonComment in jsonComments) {
//        [comments addObject:[JsonParser parseCommentFromJson:jsonComment]];
//    }
//    
//    return comments;
//}
//
//+ (OldConversation *)parseConversationFromJson:(NSDictionary *)json ignoringUserKey:(NSInteger)userKeyToIgnore
//{
//    OldConversation *conversation = [[OldConversation alloc] init];
//    conversation.key = [json[@"id"] integerValue];
//    if(json[@"mostRecentMessage"] && json[@"mostRecentMessage"] != [NSNull null]) {
//        conversation.lastMessage = [JsonParser parseMessageFromJson:json[@"mostRecentMessage"]];
//    }
//    
//    NSMutableArray *participants = [NSMutableArray array];
//    for(id jsonUser in json[@"participants"]) {
////        OldUser *user = [JsonParser parseUserFromJson:jsonUser];
////        
////        // ignore the current user that is obviously included in the conversation
////        if(user.key != userKeyToIgnore) {
////            [participants addObject:user];
////        }
//    }
//    conversation.participants = participants;
//    
//    return conversation;
//}
//
//+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations ignoringUserKey:(NSInteger)userKeyToIgnore
//{
//    NSMutableArray *conversations = [NSMutableArray array];
//    for(id jsonConversation in jsonConversations) {
//        [conversations addObject:[JsonParser parseConversationFromJson:jsonConversation ignoringUserKey:userKeyToIgnore]];
//    }
//    
//    return conversations;
//}
//
//+ (OldMessage *)parseMessageFromJson:(NSDictionary *)json
//{
//
//    OldMessage *message = [[OldMessage alloc] init];
//    message.key = [json[@"id"] integerValue];
////    message.author = [JsonParser parseUserFromJson:json[@"by"]];
//    
//    //message.date = [[DateFormatterManager sharedInstance].fullDateFormatter dateFromString:json[@"timestamp"]];
//    
//    NSDate *date;
//    NSError *error;
//    [[DateFormatterManager sharedInstance].fullDateFormatter getObjectValue:&date forString:json[@"timestamp"] range:nil error:&error];
//    message.date = date;
//    
//    message.content = json[@"text"];
//    message.seen = [json[@"seen"] boolValue];
//    
//    return message;
//}
//
//+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages
//{
//    NSMutableArray *messages = [NSMutableArray array];
//    for(id jsonMessage in jsonMessages) {
//        [messages addObject:[JsonParser parseMessageFromJson:jsonMessage]];
//    }
//    
//    return messages;
//}
//
//@end
