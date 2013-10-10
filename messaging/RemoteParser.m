//
//  RemoteParser.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteParser.h"
#import "DateFormatterManager.h"

@interface RemoteParser()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation RemoteParser

- (id)init
{
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    return self;
}

#pragma mark - Users

+ (RemoteUser *)parseUserFromJson:(NSDictionary *)json
{
    RemoteUser *user = [RemoteUser MR_createEntity];
    user.remoteKey = json[@"id"];
    user.name = json[@"username"];
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

+ (RemoteConversation *)parseConversationFromJson:(NSDictionary *)json
{
    RemoteConversation *conversation = [RemoteConversation MR_createEntity];
    conversation.remoteKey = json[@"id"];
    
//    if(json[@"mostRecentMessage"] && json[@"mostRecentMessage"] != [NSNull null]) {
//        conversation.lastMessage = [JsonParser parseMessageFromJson:json[@"mostRecentMessage"]];
//    }
//    
//    NSMutableArray *participants = [NSMutableArray array];
//    for(id jsonUser in json[@"participants"]) {
//        User *user = [JsonParser parseUserFromJson:jsonUser];
//        
//        // ignore the current user that is obviously included in the conversation
//        if(user.key != userKeyToIgnore) {
//            [participants addObject:user];
//        }
//    }
//    conversation.participants = participants;
    
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

+ (RemoteMessage *)parseMessageFromJson:(NSDictionary *)json
{
    RemoteMessage *message = [RemoteMessage MR_createEntity];
    message.remoteKey = json[@"id"];
    message.author = [RemoteParser parseUserFromJson:json[@"by"]];
    
    NSDate *date;
    NSError *error;
    [[DateFormatterManager sharedInstance].fullDateFormatter getObjectValue:&date forString:json[@"timestamp"] range:nil error:&error];
    message.date = date;
    
    message.content = json[@"text"];
//    message.seen = [json[@"seen"] boolValue];
    
    return message;
}

+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(RemoteConversation *)conversation
{
    NSMutableArray *messages = [NSMutableArray array];
    for(id jsonMessage in jsonMessages) {
        RemoteMessage *message = [RemoteParser parseMessageFromJson:jsonMessage];
        message.conversation = conversation;
        [messages addObject:message];
    }
    
    return messages;
}

@end
