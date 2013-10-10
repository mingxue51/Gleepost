//
//  RemoteParser.m
//  Gleepost
//
//  Created by Lukas on 10/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "RemoteParser.h"
#import "DateFormatterManager.h"
#import "SendStatus.h"

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
    NSNumber *key = json[@"id"];
    RemoteUser *user = [RemoteUser MR_findFirstByAttribute:@"remoteKey" withValue:key];
    if(!user) {
        user = [RemoteUser MR_createEntity];
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

+ (RemoteConversation *)parseConversationFromJson:(NSDictionary *)json
{
    RemoteConversation *conversation = [RemoteConversation MR_createEntity];
    conversation.remoteKey = json[@"id"];
    
    if(json[@"mostRecentMessage"] && json[@"mostRecentMessage"] != [NSNull null]) {
        conversation.mostRecentMessage = [RemoteParser parseMessageFromJson:json[@"mostRecentMessage"]];
    }

    NSMutableArray *participants = [NSMutableArray array];
    for(id jsonUser in json[@"participants"]) {
        RemoteUser *user = [RemoteParser parseUserFromJson:jsonUser];
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
    message.sendStatus = [NSNumber numberWithInt:kSendStatusSent];
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
