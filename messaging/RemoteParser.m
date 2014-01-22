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
#import "GLPLike.h"
#import "SessionManager.h"
#import "GLPCategory.h"

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
    user.name = json[@"name"];
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
    // get participants
    NSMutableArray *participants = [NSMutableArray array];
    for(id jsonUser in json[@"participants"]) {
        GLPUser *user = [RemoteParser parseUserFromJson:jsonUser];
        [participants addObject:user];
    }
    
    GLPConversation *conversation;
    
    // live conversation with expiry block
    NSDictionary *expiry = json[@"expiry"];
    if(expiry) {
        NSDate *expiryDate = [RemoteParser parseDateFromString:expiry[@"time"]];
        BOOL ended = [expiry[@"ended"] boolValue];
        conversation = [[GLPConversation alloc] initWithParticipants:participants expiryDate:expiryDate ended:ended];
    }
    // normal conversation
    else {
        conversation = [[GLPConversation alloc] initWithParticipants:participants];
    }
    
    conversation.remoteKey = [json[@"id"] integerValue];
    
    if(json[@"mostRecentMessage"] && json[@"mostRecentMessage"] != [NSNull null]) {
        GLPMessage *message = [RemoteParser parseMessageFromJson:json[@"mostRecentMessage"] forConversation:nil];
        conversation.lastMessage = message.content;
    }
    
    conversation.lastUpdate = [RemoteParser parseDateFromString:json[@"lastActivity"]];
    
    return conversation;
}

+(NSMutableArray*)parseNormalConversations:(NSArray*)allConversations
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

+ (NSArray *)parseConversationsFilterByLive:(BOOL)live fromJson:(NSArray *)jsonConversations
{
    NSMutableArray *conversations = [NSMutableArray array];

    for(id jsonConversation in jsonConversations) {
        BOOL filter = (live && jsonConversation[@"expiry"]) || (!live && !jsonConversation[@"expiry"]);
        if(filter) {
            [conversations addObject:[RemoteParser parseConversationFromJson:jsonConversation]];
            
            // no more than 3 live conversations
            if(live && conversations.count == 3) {
                break;
            }
        }
    }
    
    return conversations;
}

+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations
{
    NSMutableArray *conversations = [NSMutableArray array];
    
    for(id jsonConversation in jsonConversations) {
        [conversations addObject:[RemoteParser parseConversationFromJson:jsonConversation]];
    }
    
    return conversations;
}


#pragma mark - Live conversations

+ (GLPLiveConversation *)parseLiveConversationFromJson:(NSDictionary *)json
{
//    GLPLiveConversation *conversation = [[GLPLiveConversation alloc] init];
//    conversation.remoteKey = [json[@"id"] integerValue];
//    
////    if(json[@"mostRecentMessage"] && json[@"mostRecentMessage"] != [NSNull null]) {
////        GLPMessage *message = [RemoteParser parseMessageFromJson:json[@"mostRecentMessage"] forConversation:nil];
////        conversation.lastMessage = message.content;
////    }
//    
//    conversation.lastUpdate = [RemoteParser parseDateFromString:json[@"lastActivity"]];
//    
//    NSMutableArray *participants = [NSMutableArray array];
//    
//    for(id jsonUser in json[@"participants"]) {
//        GLPUser *user = [RemoteParser parseUserFromJson:jsonUser];
//        [participants addObject:user];
//    }
//    
//    conversation.participants = participants;
//    
//    NSDictionary *expired = json[@"expiry"];
//    
//    conversation.timeStarted = [RemoteParser parseDateFromString:expired[@"time"]];
//    
//    
//    [conversation setTitleFromParticipants:participants];
//
//    
//    conversation.author = [participants objectAtIndex:0];
//    //[conversation setTitleFromParticipants:participants];
//    
//    return conversation;
    return nil;
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


+(NSArray*)orderAndGetLastThreeConversations:(NSArray*)liveConversations
{
//    NSMutableArray *lastConversations = [[NSMutableArray alloc] init];
//    
//    //Order conversations by older to newer.
//    
//    NSArray *lastConversationsArray;
//    
//    lastConversationsArray = [liveConversations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        
//        
//        NSDate *first = [(GLPLiveConversation*)a timeStarted];
//        NSDate *second = [(GLPLiveConversation*)b timeStarted];
//        return [second compare:first];
//    }];
//    
//    int i = 0;
//    //Get last three conversations.
//    for(GLPLiveConversation *liveConv in lastConversationsArray)
//    {
//        [lastConversations addObject:liveConv];
//        ++i;
//        if(i==3)
//        {
//            break;
//        }
//    }
//    
//    //Reverse order of live conversations.
//    NSArray* reversedArray = [[lastConversations reverseObjectEnumerator] allObjects];
//
//    lastConversations = reversedArray.mutableCopy;
//    
//    
////    for(GLPLiveConversation *liveConversation in liveConversations)
////    {
////        for(GLPLiveConversation *liveConversation in liveConversations)
////        {
////            
////        }
////    }
//    return lastConversations;
    return nil;
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


#pragma mark - Posts, comments, likes and categories

+ (GLPPost *)parsePostFromJson:(NSDictionary *)json
{
    GLPPost *post = [[GLPPost alloc] init];
    post.remoteKey = [json[@"id"] integerValue];
    post.author = [RemoteParser parseUserFromJson:json[@"by"]];
    post.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    post.content = json[@"text"];
    

//    if([json[@"comments"] isKindOfClass:[NSArray class]])
//    {
//        post.commentsCount = 0;
//    }
//    else
//    {
        post.commentsCount = [json[@"comment_count"] integerValue];
//    }
    
    
//    if([json[@"likes"] isKindOfClass:[NSArray class]] || json[@"likes"] == [NSNull null])
//    {
//        post.likes = 0;
//    }
//    else
//    {
        post.likes = [json[@"like_count"] integerValue];
//    }
    
    post.dislikes = [json[@"hates"] integerValue];
    

    
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
    
    
    //Parse categories.
    post.categories = [self parseCategoriesFromJson:json[@"categories"] forPost:post];
    
    //Parse users' likes of the post and find if the post is liked by logged in user.
    NSArray *usersLiked = json[@"likes"];
    
    post.liked = NO;
    
    for(NSDictionary *userLiked in usersLiked)
    {
        
        NSDictionary *dict = [userLiked objectForKey:@"by"];

        NSNumber *userRemoteKey = [dict objectForKey:@"id"];
        
        if([userRemoteKey integerValue] == [[SessionManager sharedInstance]user].remoteKey)
        {
            post.liked = YES;
            break;
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

+(GLPPost*)parseIndividualPostFromJson:(NSDictionary*)json
{
    GLPPost *post = [[GLPPost alloc] init];
    post.remoteKey = [json[@"id"] integerValue];
    post.author = [RemoteParser parseUserFromJson:json[@"by"]];
    post.date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    post.content = json[@"text"];
    
    NSArray* comments = nil;

    if(json[@"comments"] == [NSNull null])
    {
        post.commentsCount = 0;
    }
    else
    {
         comments = [RemoteParser parseCommentsFromJson:json[@"comments"] forPost:post];
    }
    
    post.commentsCount = comments.count;

    
    //TODO: Parse comments.
    //post.commentsCount = [json[@"comments"] integerValue];
    
    NSArray *likes = nil;
    
    //TODO: Parse likes.
    if (json[@"likes"] == [NSNull null])
    {
        post.likes = 0;
    }
    else
    {
        likes = [RemoteParser parseLikesFromJson:json[@"likes"] forPost:post];
        post.likes = likes.count;
    }


    
    post.dislikes = [json[@"hates"] integerValue];
    
    
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

+(GLPLike *)parseLikeFromJson:(NSDictionary *)json forPost:(GLPPost *)post
{
    NSDate *date = [RemoteParser parseDateFromString:json[@"timestamp"]];
    
    GLPLike *like = [[GLPLike alloc] initWithUser:[RemoteParser parseUserFromJson:json[@"by"]] withDate:date andPost:post];
    
    return like;
    
}

+(NSArray*)parseLikesFromJson:(NSArray*)jsonLikes forPost:(GLPPost*)post
{
    NSMutableArray *likes = [NSMutableArray array];
    
    if(jsonLikes == (id)[NSNull null])
    {
        return likes;
    }
    
    for(id jsonLike in jsonLikes)
    {
        [likes addObject: [RemoteParser parseLikeFromJson:jsonLike forPost:post]];
    }
    
    return likes;
}

+(NSArray*)parseCategoriesFromJson:(NSArray*)jsonCategories forPost:(GLPPost*)post
{
    NSMutableArray *categories = [NSMutableArray array];
    
    for(NSDictionary* c in jsonCategories)
    {
        NSNumber* remoteKey = [c objectForKey:@"id"];
        
        GLPCategory *category = [[GLPCategory alloc]initWithTag:[c objectForKey:@"tag"] name:[c objectForKey:@"name"] postRemoteKey:post.remoteKey andRemoteKey:[remoteKey integerValue]];
        
        [categories addObject:category];
        
    }
    
    return categories;
}

+(NSString*)parseCategoriesToTags:(NSArray*)categories
{
    NSMutableString *delimitedCommaTags = [NSMutableString string];
    
    int i = 0;
    
    for(GLPCategory *c in categories)
    {
        if(i==categories.count-1)
        {
            //Last category don't add delimiter.
            [delimitedCommaTags appendString:[NSString stringWithFormat:@"%@",c.tag]];

        }
        else
        {
            [delimitedCommaTags appendString:[NSString stringWithFormat:@"%@,",c.tag]];
        }
        
        ++i;
    }
    
    return delimitedCommaTags;
    
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
    contact.user.remoteKey = contact.remoteKey;
    contact.user.name = json[@"name"];
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
    NSString* notificationsType = json[@"type"];
    GLPNotificationType type;

    if([notificationsType isEqualToString:@"accepted_you"])
    {
        type = kGLPNotificationTypeAcceptedYou;
    }
    else if([notificationsType isEqualToString:@"added_you"])
    {
        type = kGLPNotificationTypeAddedYou;
    }
    else if([notificationsType isEqualToString:@"commented"])
    {
        type = kGLPNotificationTypeCommented;
    }
    else if([notificationsType isEqualToString:@"liked"])
    {
        type = kGLPNotificationTypeLiked;
    }
    
    notification.notificationType = type;
    notification.seen = NO;
    
    notification.remoteKey = [json[@"id"] integerValue];
    notification.postRemoteKey = (json[@"post"] != [NSNull null]) ? [json[@"post"] intValue] : 0;
    notification.date = [RemoteParser parseDateFromString:json[@"time"]];
    notification.user = [RemoteParser parseUserFromJson:json[@"user"]];
    
    return notification;
}

+ (NSArray *)parseNotificationsFromJson:(NSArray *)jsonNotifications
{
    NSMutableArray *items = [NSMutableArray array];
    for(id item in jsonNotifications) {
        
        [items addObject:[RemoteParser parseNotificationFromJson:item]];
    }
    
    return items;
}


#pragma mark - Web socket event

+ (GLPWebSocketEvent *)parseWebSocketEventFromJson:(NSDictionary *)json
{
    GLPWebSocketEvent *event = [[GLPWebSocketEvent alloc] init];
    [event typeFromString:json[@"type"]];
    event.data = json[@"data"];
    event.location = json[@"location"];
    
    return event;
}

#pragma mark - Busy status
+(BOOL)parseBusyStatus:(NSDictionary*)json
{
    return [json[@"busy"] boolValue];
}

+ (NSString *)parseMessageFromJson:(NSDictionary *)json {
    return json[@"message"];
}




@end
