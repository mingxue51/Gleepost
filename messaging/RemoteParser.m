//
//  RemoteParser.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteParser.h"
#import "DateFormatterHelper.h"
#import "SendStatus.h"

@interface RemoteParser()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation RemoteParser

static NSDateFormatter *dateFormatter = nil;


#pragma mark - Users

+ (GLPUser *)parseUserFromJson:(NSDictionary *)json
{
    NSNumber *key = json[@"id"];
    GLPUser *user = [GLPUser MR_findFirstByAttribute:@"remoteKey" withValue:key];
    
    if(!user) {
        user = [GLPUser MR_createEntity];
        user.remoteKey = key;
        user.name = json[@"username"];
    }
    

//    
//    // optional
//    user.tagline = json[@"tagline"];
//    user.profileImageUrl = json[@"profile_image"];
//    user.course = json[@"course"];
//    
//    if(json[@"network"]) {
//        user.network = json[@"network"];
//    }
    
    return user;
}


#pragma mark - Conversations

+ (Conversation *)parseConversationFromJson:(NSDictionary *)json
{
    Conversation *conversation = [Conversation MR_createEntity];
    conversation.remoteKey = json[@"id"];
    
    if(json[@"mostRecentMessage"] && json[@"mostRecentMessage"] != [NSNull null]) {
        conversation.mostRecentMessage = [RemoteParser parseMessageFromJson:json[@"mostRecentMessage"] forConversation:conversation];
    }

    NSMutableArray *participants = [NSMutableArray array];
    for(id jsonUser in json[@"participants"]) {
        GLPUser *user = [RemoteParser parseUserFromJson:jsonUser];
        [participants addObject:user];
    }
    conversation.participants = [NSSet setWithArray:participants];
    
    return conversation;
}

+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations
{
    NSMutableArray *conversations = [NSMutableArray array];
    for(id jsonConversation in jsonConversations) {
        [conversations addObject:[RemoteParser parseConversationFromJson:jsonConversation]];
    }
    
    return conversations;
}


#pragma mark - Messages

+ (GLPMessage *)parseMessageFromJson:(NSDictionary *)json forConversation:(Conversation *)conversation
{
    GLPMessage *message = [GLPMessage MR_createEntity];
    message.remoteKey = json[@"id"];
    message.author = [RemoteParser parseUserFromJson:json[@"by"]];
    message.conversation = conversation;
    message.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    message.content = json[@"text"];
    message.sendStatus = [NSNumber numberWithInt:kSendStatusSent];
    message.seenValue = [json[@"seen"] boolValue];
    
    NSLog(@"message %@ date %@", message.content, message.date);
    
    return message;
}

+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(Conversation *)conversation
{
    NSMutableArray *messages = [NSMutableArray array];
    for(id jsonMessage in jsonMessages) {
        GLPMessage *message = [RemoteParser parseMessageFromJson:jsonMessage forConversation:conversation];
        [messages addObject:message];
    }
    
    return messages;
}


#pragma mark - Posts and comments

+ (Post *)parsePostFromJson:(NSDictionary *)json
{
    Post *post = [Post MR_createEntity];
    post.remoteKey = json[@"id"];
    post.author = [RemoteParser parseUserFromJson:json[@"by"]];
    post.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    post.content = json[@"text"];
    post.commentsCount = json[@"comments"];
    post.likes = json[@"likes"];
    post.dislikes = json[@"hates"];
    
    return post;
}

+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts
{
    NSMutableArray *posts = [NSMutableArray array];
    for(id postJson in jsonPosts) {
        Post *post = [RemoteParser parsePostFromJson:postJson];
        [posts addObject:post];
    }
    
    return posts;
}

+ (Comment *)parseCommentFromJson:(NSDictionary *)json forPost:(Post *)post
{
    Comment *comment = [Comment MR_createEntity];
    comment.remoteKey = json[@"id"];
    comment.author = [RemoteParser parseUserFromJson:json[@"by"]];
    comment.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    comment.content = json[@"text"];
    comment.post = post;
    
    return comment;
}

+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments forPost:(Post *)post
{
    NSMutableArray *comments = [NSMutableArray array];
    for(id jsonComment in jsonComments) {
        [comments addObject:[RemoteParser parseCommentFromJson:jsonComment forPost:post]];
    }
    
    return comments;
}


#pragma mark - Commons

+ (NSDateFormatter *)getDateFormatter
{
    if(!dateFormatter) {
        dateFormatter = [DateFormatterHelper createRemoteDateFormatter];
    }
    
    return dateFormatter;
}

+ (NSDate *)parseDateFromString:(NSString *)string
{
    NSDate *date;
    NSError *error;
    [[self getDateFormatter] getObjectValue:&date forString:string range:nil error:&error];
    
    NSLog(@"Remote date parsed %@ for string %@", date, string);
    
    return date;
}

@end
