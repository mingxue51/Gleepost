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
static NSDateFormatter *dateFormatterWithNanoSeconds = nil;

#pragma mark - Users

+ (GLPUser *)parseUserFromJson:(NSDictionary *)json
{
    GLPUser *user = [[GLPUser alloc] init];
    user.remoteKey = [json[@"id"] integerValue];
    user.name = json[@"username"];
    user.course = json[@"course"];
    user.personalMessage = json[@"tagline"];
    user.profileImageUrl = json[@"profile_image"];

    
    NSDictionary* network = json[@"network"];
    
//    NSLog(@"Whole Network: %@", network);
    
    
    
//    GLPUser *user = [GLPUser MR_findFirstByAttribute:@"remoteKey" withValue:key];
//    
//    if(!user) {
//
//    }
    
    if(json[@"network"] != nil)
    {
        NSArray *networkMessages = [self parseNetworkUser:json[@"network"]];
        
        user.networkId = [[networkMessages objectAtIndex:0] integerValue];
        
        user.networkName = [networkMessages objectAtIndex:1];
        
        NSLog(@"Network id: %d, Network Name: %@", user.networkId, user.networkName);
    }
    


//
//    // optional
//    user.tagline = json[@"tagline"];
    user.profileImageUrl = json[@"profile_image"];
//    NSLog(@"User's image URL: %@", json[@"profile_image"]);
//    NSLog(@"User's course: %@",json[@"course"]);
    
//    user.course = json[@"course"];
//    
//    if(json[@"network"]) {
//        user.network = json[@"network"];
//    }
    
    return user;
}

+(NSArray*)parseNetworkUser:(NSDictionary *)json
{
    NSMutableArray *networkContent = [[NSMutableArray alloc] init];
    
//    for(id jsonUser in json[@"network"])
//    {
//        NSLog(@"Network: %@",jsonUser);
    
    [networkContent addObject:json[@"id"]];
    [networkContent addObject:json[@"name"]];
    
//    }
    
    return networkContent;
}


#pragma mark - Conversations

+ (GLPConversation *)parseConversationFromJson:(NSDictionary *)json
{
    GLPConversation *conversation = [[GLPConversation alloc] init];
    conversation.remoteKey = [json[@"id"] integerValue];
    
    if(json[@"mostRecentMessage"] && json[@"mostRecentMessage"] != [NSNull null]) {
        GLPMessage *message = [RemoteParser parseMessageFromJson:json[@"mostRecentMessage"] forConversation:nil];
        conversation.lastMessage = message.content;
        conversation.lastUpdate = message.date;
    }


    
   // NSMutableArray *participants = [NSMutableArray array];
    NSMutableArray *participants = [[NSMutableArray alloc] init];

    for(id jsonUser in json[@"participants"]) {
        
        GLPUser *user = [RemoteParser parseUserFromJson:jsonUser];
        [participants addObject:user];
    }
    
    
    
    conversation.author = [participants objectAtIndex:0];

    
    [conversation setTitleFromParticipants:participants];
    
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

+ (GLPMessage *)parseMessageFromJson:(NSDictionary *)json forConversation:(GLPConversation *)conversation
{
    GLPMessage *message = [[GLPMessage alloc] init];
    message.remoteKey = [json[@"id"] integerValue];
    message.author = [RemoteParser parseUserFromJson:json[@"by"]];
    message.conversation = conversation;
    message.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    message.content = json[@"text"];
    message.sendStatus = kSendStatusSent;
    message.seen = [json[@"seen"] boolValue];
    
    return message;
}

+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forConversation:(GLPConversation *)conversation
{
    NSMutableArray *messages = [NSMutableArray array];
    for(id jsonMessage in jsonMessages) {
        GLPMessage *message = [RemoteParser parseMessageFromJson:jsonMessage forConversation:conversation];
        [messages addObject:message];
    }
    
    return messages;
}

+ (GLPMessage *)parseMessageFromLongPollJson:(NSDictionary *)json
{
    GLPMessage *message = [RemoteParser parseMessageFromJson:json forConversation:nil];
    message.conversation = [[GLPConversation alloc] init];
    message.conversation.remoteKey = [json[@"conversation_id"] integerValue];
    
    return message;
}


#pragma mark - Posts and comments

+ (GLPPost *)parsePostFromJson:(NSDictionary *)json
{
    GLPPost *post = [[GLPPost alloc] init];
    post.remoteKey = [json[@"id"] integerValue];
    post.author = [RemoteParser parseUserFromJson:json[@"by"]];
    post.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    post.content = json[@"text"];
    post.commentsCount = [json[@"comments"] integerValue];
    post.likes = [json[@"likes"] integerValue];
    post.dislikes = [json[@"hates"] integerValue];
    

//    NSLog(@"Posts JSON: %@",json);
//    NSLog(@"User's image JSON: %@",post.author.profileImageUrl);
    
    // should work.. or not!
    //post.imagesUrls = json[@"images"];
    
    NSArray *jsonArray = json[@"images"];
    
    if(jsonArray == (id)[NSNull null])
    {
        post.imagesUrls = nil;
    }
    else
    {
        if(jsonArray.count > 0)
        {
            NSMutableArray *imagesUrls = [NSMutableArray arrayWithCapacity:jsonArray.count];
            
            for(NSString *url in jsonArray)
            {
                [imagesUrls addObject:url];
            }
            post.imagesUrls = imagesUrls;
        } else
        {
            post.imagesUrls = [NSArray array];
        }
    }
    

//    
//    NSArray *jsonArray = json[@"images"];
//    
//    if(jsonArray.count > 0) {
//        NSMutableArray *imagesUrls = [NSMutableArray arrayWithCapacity:jsonArray.count];
//        for(NSString *url in jsonArray) {
//            [imagesUrls addObject:url];
//        }
//        post.imagesUrls = imagesUrls;
//    } else {
//        post.imagesUrls = [NSArray array];
//    }
    
    
    
    return post;
}

+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts
{
    NSMutableArray *posts = [NSMutableArray array];
    for(id postJson in jsonPosts) {
        GLPPost *post = [RemoteParser parsePostFromJson:postJson];
        [posts addObject:post];
    }
    
    return posts;
}

+ (GLPComment *)parseCommentFromJson:(NSDictionary *)json forPost:(GLPPost *)post
{
    GLPComment *comment = [[GLPComment alloc] init];
    comment.remoteKey = [json[@"id"] integerValue];
    comment.author = [RemoteParser parseUserFromJson:json[@"by"]];
    comment.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    comment.content = json[@"text"];
    comment.post = post;
    
    return comment;
}

+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments forPost:(GLPPost *)post
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

+ (NSDateFormatter *)getDateFormatterWithNanoSeconds
{
    if(!dateFormatterWithNanoSeconds) {
        dateFormatterWithNanoSeconds = [DateFormatterHelper createRemoteDateFormatterWithNanoSeconds];
    }
    
    return dateFormatterWithNanoSeconds;
}

+ (NSDate *)parseDateWithoutNanoSecondsFromString:(NSString *)string
{
    NSDate *date;
    NSError *error;
    
    [[RemoteParser getDateFormatter] getObjectValue:&date forString:string range:nil error:&error];
    
    return date;
}

+ (NSDate *)parseDateWithNanoSecondsFromString:(NSString *)string
{
    NSDate *date;
    NSError *error;
    
    [[RemoteParser getDateFormatterWithNanoSeconds] getObjectValue:&date forString:string range:nil error:&error];
    
    return date;
}

+ (NSDate *)parseDateFromString:(NSString *)string
{
    NSDate *date = [RemoteParser parseDateWithoutNanoSecondsFromString:string];

    if(!date) {
        date = [RemoteParser parseDateWithNanoSecondsFromString:string];
    }
    
    NSAssert(date, @"Parsed date null", @"String value %@", string);
    
    return date;
}

@end
