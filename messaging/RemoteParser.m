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

    
    if(json[@"network"] != nil)
    {
        NSArray *networkMessages = [self parseNetworkUser:json[@"network"]];
        
        user.networkId = [[networkMessages objectAtIndex:0] integerValue];
        
        user.networkName = [networkMessages objectAtIndex:1];
    }
    
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
    }
    
    conversation.lastUpdate = [RemoteParser parseDateFromString:json[@"lastActivity"]];
    
    NSMutableArray *participants = [NSMutableArray array];

    for(id jsonUser in json[@"participants"]) {
        GLPUser *user = [RemoteParser parseUserFromJson:jsonUser];
        [participants addObject:user];
    }
    
    conversation.isGroup = (participants.count > 2) ? YES : NO;

    
    conversation.author = [participants objectAtIndex:0];
    [conversation setTitleFromParticipants:participants];
    
    return conversation;
}

+(NSMutableArray*)findRegularConversations:(NSArray*)allConversations
{
    NSMutableArray *finalConversations = [[NSMutableArray alloc] init];
    
    for(id jsonConversation in allConversations)
    {
        if(jsonConversation[@"expiry"]==nil)
        {
            [finalConversations addObject:jsonConversation];
        }
    }
    
    return finalConversations;
}

+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations
{
    //Separate regular conversations from live conversations.
    
    NSMutableArray *jsonRegularConversations = [RemoteParser findRegularConversations:jsonConversations];
 
    NSMutableArray *conversations = [NSMutableArray array];

    
    for(id jsonConversation in jsonRegularConversations)
    {
        [conversations addObject:[RemoteParser parseConversationFromJson:jsonConversation]];
    }
    
    return conversations;

    
//    NSMutableArray *conversations = [NSMutableArray array];
//    for(id jsonConversation in jsonConversations) {
//        [conversations addObject:[RemoteParser parseConversationFromJson:jsonConversation]];
//    }
//    
//    return conversations;
}

#pragma mark - Live conversations

+ (GLPLiveConversation *)parseLiveConversationFromJson:(NSDictionary *)json
{
    GLPLiveConversation *conversation = [[GLPLiveConversation alloc] init];
    conversation.remoteKey = [json[@"id"] integerValue];
    
//    if(json[@"mostRecentMessage"] && json[@"mostRecentMessage"] != [NSNull null]) {
//        GLPMessage *message = [RemoteParser parseMessageFromJson:json[@"mostRecentMessage"] forConversation:nil];
//        conversation.lastMessage = message.content;
//    }
    
    conversation.lastUpdate = [RemoteParser parseDateFromString:json[@"lastActivity"]];
    
    NSMutableArray *participants = [NSMutableArray array];
    
    for(id jsonUser in json[@"participants"]) {
        GLPUser *user = [RemoteParser parseUserFromJson:jsonUser];
        [participants addObject:user];
    }
    
    conversation.participants = participants;
    
    NSDictionary *expired = json[@"expiry"];
    
    conversation.timeStarted = [RemoteParser parseDateFromString:expired[@"time"]];
    
    
    [conversation setTitleFromParticipants:participants];

    
    conversation.author = [participants objectAtIndex:0];
    //[conversation setTitleFromParticipants:participants];
    
    return conversation;
}

+(NSMutableArray*)findLiveConversations:(NSArray*)allConversations
{
    NSMutableArray *finalConversations = [[NSMutableArray alloc] init];
    
    for(id jsonConversation in allConversations)
    {
        if(jsonConversation[@"expiry"]!=nil)
        {
            [finalConversations addObject:jsonConversation];
        }
    }
    
    return finalConversations;
}
+ (NSArray *)parseLiveConversationsFromJson:(NSArray *)jsonConversations
{
    //Separate regular conversations from live conversations.
    
    NSMutableArray *jsonRegularConversations = [RemoteParser findLiveConversations:jsonConversations];
    
    NSMutableArray *conversations = [NSMutableArray array];
    
    
    for(id jsonConversation in jsonRegularConversations)
    {
        [conversations addObject:[RemoteParser parseLiveConversationFromJson:jsonConversation]];
    }
    
    return conversations;
    
    
    //    NSMutableArray *conversations = [NSMutableArray array];
    //    for(id jsonConversation in jsonConversations) {
    //        [conversations addObject:[RemoteParser parseConversationFromJson:jsonConversation]];
    //    }
    //
    //    return conversations;
}

/**
 
 TODO: TEST THIS!!!
 */
+(NSArray*)orderAndGetLastThreeConversations:(NSArray*)liveConversations
{
    NSMutableArray *lastConversations = [[NSMutableArray alloc] init];
    
    //Order conversations by older to newer.
    
    NSArray *lastConversationsArray;
    
    lastConversationsArray = [liveConversations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        
        NSDate *first = [(GLPLiveConversation*)a expiry];
        NSDate *second = [(GLPLiveConversation*)b expiry];
        return [first compare:second];
    }];
    
    int i = 0;
    //Get last three conversations.
    for(GLPLiveConversation *liveConv in lastConversationsArray)
    {
        [lastConversations addObject:liveConv];
        ++i;
        if(i==3)
        {
            break;
        }
    }
    
    
    
//    for(GLPLiveConversation *liveConversation in liveConversations)
//    {
//        for(GLPLiveConversation *liveConversation in liveConversations)
//        {
//            
//        }
//    }
    return lastConversations;
}

//TODO: Shrink two different type of messages methods to one type. Use inheritance in live conversation and conversation.
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

+ (GLPMessage *)parseMessageFromJson:(NSDictionary *)json forLiveConversation:(GLPLiveConversation *)conversation
{
    GLPMessage *message = [[GLPMessage alloc] init];
    message.remoteKey = [json[@"id"] integerValue];
    message.author = [RemoteParser parseUserFromJson:json[@"by"]];
    message.liveConversation = conversation;
    message.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    message.content = json[@"text"];
    message.sendStatus = kSendStatusSent;
    message.seen = [json[@"seen"] boolValue];
    
    return message;
}

+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages forLiveConversation:(GLPLiveConversation *)conversation
{
    
    NSMutableArray *messages = [NSMutableArray array];
    for(id jsonMessage in jsonMessages) {
        GLPMessage *message = [RemoteParser parseMessageFromJson:jsonMessage forLiveConversation:conversation];
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

#pragma mark - Contacts

+ (NSArray*)parseContactsFromJson:(NSArray *)jsonContacts
{
//    NSLog(@"Load Contacts JSON: %@", jsonContacts);
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    for (id contactJson in jsonContacts)
    {
        [contacts addObject:[RemoteParser parseContactFromJson:contactJson]];
    }
    
    return contacts;
}

+(GLPContact* )parseContactFromJson:(NSDictionary*) json
{
    GLPContact *contact = [[GLPContact alloc] init];
    
    contact.user = [[GLPUser alloc] init];
    
    
    contact.remoteKey = [json[@"id"] integerValue];
    contact.user.name = json[@"username"];
    contact.user.profileImageUrl = json[@"profile_image"];
    contact.youConfirmed = [json[@"you_confirmed"] boolValue];
    contact.theyConfirmed = [json[@"they_confirmed"] boolValue];
    
    return contact;
}


/***
 
 + (GLPUser *)parseUserFromJson:(NSDictionary *)json
 {
 GLPUser *user = [[GLPUser alloc] init];
 user.remoteKey = [json[@"id"] integerValue];
 user.name = json[@"username"];
 user.course = json[@"course"];
 user.personalMessage = json[@"tagline"];
 user.profileImageUrl = json[@"profile_image"];

 
 */

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
    
    //formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    return dateFormatterWithNanoSeconds;
}

+ (NSDate *)parseDateWithoutNanoSecondsFromString:(NSString *)string
{
    if(!string) {
        return nil;
    }
    
    NSDate *date;
    NSError *error;
    
    [[RemoteParser getDateFormatter] getObjectValue:&date forString:string range:nil error:&error];
    
    return date;
}

+ (NSDate *)parseDateWithNanoSecondsFromString:(NSString *)string
{
    if(!string) {
        return nil;
    }
    
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

+(NSString*)parseRegisterErrorMessage:(NSString*)error
{
    //NSLog(@"ERRORS: %@  %@  %@  %@  %@  %@  %@ ",error.domain, error.userInfo, error.localizedDescription, error.localizedRecoveryOptions, error.localizedRecoverySuggestion, error.localizedFailureReason, error.recoveryAttempter);
    
    if ([error rangeOfString:@"Username or email"].location == NSNotFound)
    {
        return @"Short password typed";
    }
    else
    {
        return @"Username or email address already taken";
    }
    
//    NSLog(@"Suggested error: %@", error);
//    
//    return error.description;
}

#pragma mark - Images

+(NSString*)parseImageUrl:(NSString*)url
{
    
    NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return json[@"url"];
}

+(int)parseIdFromJson:(NSDictionary*)json
{
    //NSLog(@"POST ID: %@",json[@"id"]);
    
    return [json[@"id"] integerValue];
}


#pragma mark - Notifications

+ (GLPNotification *)parseNotificationFromJson:(NSDictionary *)json
{
    GLPNotification *notification = [[GLPNotification alloc] init];
    notification.remoteKey = [json[@"id"] integerValue];
    notification.postRemoteKey = (json[@"post"] && json[@"post"] != [NSNull null]) ? [json[@"post"] intValue] : 0;
    notification.date = [RemoteParser parseDateFromString:json[@"time"]];
    notification.user = [RemoteParser parseUserFromJson:json[@"by"]];
    
    return notification;
}

+ (NSArray *)parseNotificationsFromJson:(NSArray *)jsonConversations
{
    NSMutableArray *items = [NSMutableArray array];
    for(id item in items) {
        [items addObject:[RemoteParser parseNotificationFromJson:item]];
    }
    
    return items;
}


@end
