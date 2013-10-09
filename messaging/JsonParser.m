//
//  JsonParser.m
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "JsonParser.h"
#import "DateFormatterManager.h"

@implementation JsonParser

+ (User *)parseUserFromJson:(NSDictionary *)json
{
    User *user = [[User alloc] init];
    user.remoteId = [json[@"id"] integerValue];
    user.name = json[@"username"];
    
    return user;
}

+ (Post *)parsePostFromJson:(NSDictionary *)json
{
    Post *post = [[Post alloc] init];
    post.remoteId = [json[@"id"] integerValue];
    post.user = [JsonParser parseUserFromJson:json[@"by"]];
    post.date = [[DateFormatterManager sharedInstance].fullDateFormatter dateFromString:json[@"timestamp"]];
    post.content = json[@"text"];
    post.itemsCount = [json[@"comments"] integerValue];
    post.socialContent.likes = [json[@"likes"] integerValue];
    post.socialContent.hates = [json[@"hates"] integerValue];
    
    return post;
}

+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts
{
    NSMutableArray *posts = [NSMutableArray array];
    for(id postJson in jsonPosts) {
        Post *post = [JsonParser parsePostFromJson:postJson];
        [posts addObject:post];
    }
    
    return posts;
}

+ (Comment *)parseCommentFromJson:(NSDictionary *)json
{
    Comment *comment = [[Comment alloc] init];
    comment.remoteId = [json[@"id"] integerValue];
    comment.user = [JsonParser parseUserFromJson:json[@"by"]];
    comment.date = [[DateFormatterManager sharedInstance].fullDateFormatter dateFromString:json[@"timestamp"]];
    comment.content = json[@"text"];
    
    return comment;
}

+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments
{
    NSMutableArray *comments = [NSMutableArray array];
    for(id jsonComment in jsonComments) {
        [comments addObject:[JsonParser parseCommentFromJson:jsonComment]];
    }
    
    return comments;
}

+ (Conversation *)parseConversationFromJson:(NSDictionary *)json ignoringUser:(User *)userToIgnore
{
    Conversation *conversation = [[Conversation alloc] init];
    conversation.remoteId = [json[@"id"] integerValue];
    conversation.lastMessage = [JsonParser parseMessageFromJson:json[@"mostRecentMessage"]];
    
    NSMutableArray *participants = [NSMutableArray array];
    for(id jsonUser in json[@"participants"]) {
        User *user = [JsonParser parseUserFromJson:jsonUser];
        if(userToIgnore && user.remoteId != userToIgnore.remoteId) {
            [participants addObject:user];
        }
    }
    conversation.participants = participants;
    
    return conversation;
}

+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations ignoringUser:(User *)userToIgnore
{
    NSMutableArray *conversations = [NSMutableArray array];
    for(id jsonConversation in jsonConversations) {
        [conversations addObject:[JsonParser parseConversationFromJson:jsonConversation ignoringUser:userToIgnore]];
    }
    
    return conversations;
}

+ (Message *)parseMessageFromJson:(NSDictionary *)json
{
    Message *message = [[Message alloc] init];
    message.remoteId = [json[@"id"] integerValue];
    message.author = [JsonParser parseUserFromJson:json[@"by"]];
    message.date = [[DateFormatterManager sharedInstance].fullDateFormatter dateFromString:json[@"timestamp"]];
    message.content = json[@"text"];
    message.seen = [json[@"seen"] boolValue];
    
    return message;
}

+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages
{
    NSMutableArray *messages = [NSMutableArray array];
    for(id jsonMessage in jsonMessages) {
        [messages addObject:[JsonParser parseMessageFromJson:jsonMessage]];
    }
    
    return messages;
}

@end
