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
#import "GLPVideo.h"
#import "GLPLocation.h"
#import "GLPMember.h"
#import "GLPConversationRead.h"
#import "GLPReviewHistory.h"
#import "GLPSystemMessage.h"

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
    user.fullName = json[@"full_name"];
    user.course = json[@"course"];
    user.personalMessage = json[@"tagline"];
    user.profileImageUrl = json[@"profile_image"];
    
    user.rsvpCount = json[@"rsvp_count"];
    user.groupCount = json[@"group_count"];
    user.postsCount = json[@"post_count"];
    
    if(json[@"network"] != nil)
    {
        NSArray *networkMessages = [self parseNetworkUser:json[@"network"]];
        
        user.networkId = [[networkMessages objectAtIndex:0] integerValue];
        
        user.networkName = [networkMessages objectAtIndex:1];
    }
    
    return user;
}

+ (NSArray *)parseUsersFromJson:(NSArray *)jsonArray
{
    NSMutableArray *objects = [NSMutableArray array];
    
    for(id json in jsonArray) {
        GLPUser *object = [RemoteParser parseUserFromJson:json];
        [objects addObject:object];
    }
    
    return objects;
}

+ (NSArray *)parseAttendeesFromJson:(NSDictionary *)jsonDictionary
{
    return [RemoteParser parseUsersFromJson:jsonDictionary[@"attendees"]];
}

+ (NSArray *)parseMembersFromJson:(NSArray *)jsonArray withGroupRemoteKey:(int)groupRemoteKey
{
    NSMutableArray *members = [NSMutableArray array];
        
    for(id json in jsonArray) {
//        GLPUser *object = [RemoteParser parseUserFromJson:json];
//        object.networkId = groupRemoteKey;
        GLPMember *member = [RemoteParser parseMemberFromJson:json withGroupRemoteKey:groupRemoteKey];
        [members addObject:member];
    }
    
    return members;
}

+ (GLPMember *)parseMemberFromJson:(NSDictionary *)json withGroupRemoteKey:(NSInteger)groupRemoteKey
{
    GLPUser *user = [RemoteParser parseUserFromJson:json];
    
    NSDictionary *role = json[@"role"];
    
    GLPMember *member = [[GLPMember alloc] initWithUser:user andRoleNumber:[role[@"level"] integerValue]];
    
    member.groupRemoteKey = groupRemoteKey;
    
    return member;
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

#pragma mark - User's pending posts

+ (NSArray *)parsePendingPostsFromJson:(NSArray *)jsonPosts
{
    NSMutableArray *posts = [NSMutableArray array];
    
    for(id postJson in jsonPosts)
    {
        GLPPost *post = [RemoteParser parsePostFromJson:postJson];
        
        post.reviewHistory = [RemoteParser parseReviewHistories:postJson[@"review_history"]];
        
        post.pendingInEditMode = YES;
        
        post.sendStatus = kSendStatusSent;
        
        [posts addObject:post];
    }
    
    return posts;
}

+ (NSMutableArray *)parseReviewHistories:(NSArray *)jsonHistories
{
    NSMutableArray *reviewHistories = [[NSMutableArray alloc] init];
    
    for(NSDictionary *reviewHistoryJson in jsonHistories)
    {
        [reviewHistories addObject: [RemoteParser parseReviewHistory:reviewHistoryJson]];
    }
    
    
    return reviewHistories;
}

+ (GLPReviewHistory *)parseReviewHistory:(NSDictionary *)jsonHistory
{
    return [[GLPReviewHistory alloc] initWithActionString:jsonHistory[@"action"] withDateHappened:[RemoteParser parseDateFromString:jsonHistory[@"at"]] reason:jsonHistory[@"reason"] andUser:[RemoteParser parseUserFromJson:jsonHistory[@"by"]]];
}

#pragma mark - Approval

+ (NSInteger)parseApprovalLevel:(NSDictionary *)approvalLevel
{
    return [approvalLevel[@"level"] integerValue];
}

+ (NSString *)generateServerUserNameTypeWithNameSurname:(NSString *)nameSurname
{
    NSRange range = [nameSurname rangeOfString:@" "];
    
    if(range.location == NSNotFound)
    {
        return nameSurname;
    }
    else
    {
        NSMutableString *finalStr = nameSurname.mutableCopy;
        
        [finalStr replaceCharactersInRange:range withString:@"%20"];
        
        return finalStr;
    }
}

#pragma mark - Conversations

+ (GLPConversation *)parseConversationFromJson:(NSDictionary *)json
{
    // get participants
    NSMutableArray *participants = [NSMutableArray array];
    id participantsJson = json[@"participants"];
    if(!participantsJson || ![participantsJson isKindOfClass:[NSArray class]]) {
        DDLogError(@"Invalid json, missing participants: %@", json);
        return nil;
    }
    
    for(id jsonUser in participantsJson) {
        GLPUser *user = [RemoteParser parseUserFromJson:jsonUser];
        [participants addObject:user];
    }
    
    if(participants.count < 2) {
        DDLogError(@"Ignore conversation that does not contain at least 2 participants");
        return nil;
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
        conversation.lastMessage = ([message isKindOfClass:[GLPSystemMessage class]]) ? [(GLPSystemMessage *)message systemContent] : message.content;
    }
    
    conversation.lastUpdate = [RemoteParser parseDateFromString:json[@"lastActivity"]];
    
    //Parse last read for participants.
    [conversation setReads: [RemoteParser parseLastRead:json[@"read"] withParticipants:participants]];
    
    conversation.groupRemoteKey = [json[@"group"] integerValue];
    
    return conversation;
}

+ (NSArray *)parseLastRead:(NSArray *)jsonArray withParticipants:(NSArray *)participants
{
    NSMutableArray *readParticipants = [[NSMutableArray alloc] init];
    
    for (NSDictionary *entry in jsonArray)
    {
        NSInteger lastParticipantRemoteKey = [entry[@"user"] integerValue];
        NSInteger lastMessageReadRemoteKey = [entry[@"last_read"] integerValue];
        
        for(GLPUser *user in participants)
        {
            if(user.remoteKey == lastParticipantRemoteKey)
            {
                [readParticipants addObject:[[GLPConversationRead alloc] initWithParticipant:user andMessageRemoteKey:lastMessageReadRemoteKey]];
                
                break;
            }
        }
        
    }
    
    return readParticipants;
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
        GLPConversation *c = [RemoteParser parseConversationFromJson:jsonConversation];
        if(c) {
            [conversations addObject:c];
        }
    }
    
    return conversations;
}

+ (NSString *)generateParticipandsUserIdFormat:(NSArray *)users
{
    NSMutableString *parsedUsers = [[NSMutableString alloc] init];
    
    for(GLPUser *user in users)
    {
        [parsedUsers appendFormat:@"%ld,", (long)user.remoteKey];
    }
    
    [parsedUsers deleteCharactersInRange:NSMakeRange(parsedUsers.length - 1, 1)];
    
    return parsedUsers;
    
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
//    message.belongsToGroup = [json[@"group"] boolValue];
    message.belongsToGroup = [conversation groupRemoteKey] != 0 ? YES : NO;

    
    BOOL systemMessage = [json[@"system"] boolValue];
    
    if(systemMessage)
    {
        return [[GLPSystemMessage alloc] initWithMessage:message];
    }

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

    post.commentsCount = [json[@"comment_count"] integerValue];

    post.likes = [json[@"like_count"] integerValue];
    
    post.dislikes = [json[@"hates"] integerValue];
    
    if(json[@"attribs"])
    {
        NSDictionary *attributes = json[@"attribs"];
        
        if([attributes objectForKey:@"location-gps"])
        {
            NSArray *latLon = [RemoteParser parseLatitudeLongitudeWithGpsLocation: [attributes objectForKey:@"location-gps"]];
            
            double lat = [((NSNumber *)latLon[0]) doubleValue];
            
            double lon = [((NSNumber *)latLon[1]) doubleValue];
            
            
            post.location = [[GLPLocation alloc] initWithName:[attributes objectForKey:@"location-name"] address:[attributes objectForKey:@"location-desc"] latitude:lat longitude:lon andDistance:0];
        }
        
        if([attributes objectForKey:@"event-time"])
        {
            post.dateEventStarts = [RemoteParser parseDateFromString:[attributes objectForKey:@"event-time"]];
            post.eventTitle = [attributes objectForKey:@"title"];
        }
    }
    
    post.popularity = [json[@"popularity"] integerValue];
    post.attendees = [json[@"attendee_count"] integerValue];
    
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
    
    post.video = [RemoteParser parseVideosData:json[@"videos"]];
    
    //Parse categories.
    post.categories = [self parseCategoriesFromJson:json[@"categories"] forPost:post];

    //Parse users' likes of the post and find if the post is liked by logged in user.
    NSArray *usersLiked = json[@"likes"];
    
    post.liked = NO;
    
    if(usersLiked && usersLiked != (id)[NSNull null])
    {
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
    }
    
    post.viewsCount = [json[@"views"] integerValue];
    
    post.group = [RemoteParser parseGroupFromJson:json[@"network"]];
    
    if(json[@"review_history"])
    {
        post.reviewHistory = [RemoteParser parseReviewHistories:json[@"review_history"]];
    }
    
    post.attended = [json[@"attending"] boolValue];
    
    return post;
}

+ (GLPVideo *)parseVideosData:(NSArray *)jsonArray
{
    if(jsonArray == (id)[NSNull null])
    {
        return nil;
    }
    else
    {
        if(jsonArray.count > 0)
        {
            //TODO: After the creation of an array of videos in GLPPost model
            //      re-implement that.
            
//            NSMutableArray *videosData = [NSMutableArray arrayWithCapacity:jsonArray.count];
            
//            for(NSString *url in jsonArray)
//            {
//                [videosUrls addObject:url];
//            }

            NSDictionary *videoData = jsonArray[0];
      
            NSArray *thumbnailArray = videoData[@"thumbnails"];
            
            return [[GLPVideo alloc] initWithUrl:videoData[@"mp4"] andThumbnailUrl:thumbnailArray[0]];
        }
        else
        {
            return nil;
        }
    }
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

+ (NSArray *)parsePostsFromJson:(NSArray *)jsonPosts withGroupRemoteKey:(NSInteger)groupRemoteKey
{
    NSMutableArray *posts = [NSMutableArray array];
    
    for(id postJson in jsonPosts)
    {
        GLPPost *post = [RemoteParser parsePostFromJson:postJson];
        post.group = [[GLPGroup alloc] init];
        post.group.remoteKey = groupRemoteKey;
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

#pragma mark - Attendees

+(NSInteger)parseNewPopularity:(NSDictionary *)json
{
    return [json[@"popularity"] integerValue];
}

+(NSArray *)parseAttendees:(NSDictionary *)json
{
    NSArray *usersJson = json[@"attendees"];
    
    return [RemoteParser parseUsersFromJson:usersJson];
}

+(NSInteger)parseAttendeesCount:(NSDictionary *)json
{
    return [json[@"attendee_count"] integerValue];
}

#pragma mark - Groups

+ (NSArray *)parseGroupsFromJson:(NSArray *)json
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    for(id group in json)
    {
        [groups addObject:[RemoteParser parseGroupFromJson:group]];
    }
    
    return groups;
}

+ (GLPGroup *)parseGroupFromJson:(NSDictionary *)json
{
    GLPGroup *group = [[GLPGroup alloc] initWithName:json[@"name"] andRemoteKey:[json[@"id"] integerValue]];
    
    group.groupDescription = json[@"description"];
    group.groupImageUrl = json[@"image"];
    group.author = [RemoteParser parseMemberFromJson:json[@"creator"] withGroupRemoteKey:group.remoteKey];
    group.loggedInUser = [RemoteParser parseLoggedInUserRoleWithJson:json[@"role"]];
    group.membersCount = [json[@"size"] integerValue];
    group.conversationRemoteKey = [json[@"conversation"] integerValue];
    [group setPrivacyWithString:json[@"privacy"]];
        
    return group;
}

+ (GLPMember *)parseLoggedInUserRoleWithJson:(NSDictionary *)json
{
    GLPMember *loggedInUser = [[GLPMember alloc] initWithUser:[SessionManager sharedInstance].user andRoleNumber:[json[@"level"] integerValue]];
        
    return loggedInUser;
}

+ (GLPPost *)parsePostGroupFromJson:(NSDictionary *)json
{
    GLPPost *groupPost = [RemoteParser parsePostFromJson:json];
    groupPost.group = [RemoteParser parseGroupFromJson:json[@"network"]];
    return groupPost;
}

+ (NSArray *)parsePostsGroupFromJson:(NSArray *)jsonPosts
{
    NSMutableArray *groupPosts = [[NSMutableArray alloc] init];
    
    for(id groupPost in jsonPosts)
    {
        [groupPosts addObject:[RemoteParser parsePostGroupFromJson:groupPost]];
    }
    
    return groupPosts;
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

+ (NSArray *)parseLatitudeLongitudeWithGpsLocation:(NSString *)gpsLocation
{
    NSArray *coordinates = [gpsLocation componentsSeparatedByString:@","];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    NSNumber *latitude = [f numberFromString:((NSString *)coordinates[0])];
    NSNumber *longitude = [f numberFromString:((NSString *)coordinates[1])];

    
    return @[latitude, longitude];
}

#pragma mark - Error messages

+(NSString*)parseRegisterErrorMessage:(NSString*)error
{
    //NSLog(@"ERRORS: %@  %@  %@  %@  %@  %@  %@ ",error.domain, error.userInfo, error.localizedDescription, error.localizedRecoveryOptions, error.localizedRecoverySuggestion, error.localizedFailureReason, error.recoveryAttempter);
    
    DDLogInfo(@"Error message during registration: %@", error);
    
    
    if ([error rangeOfString:@"Username or email"].location != NSNotFound)
    {
        return @"Username or email address already taken";
    }
    else if([error rangeOfString:@"Invalid Email"].location != NSNotFound)
    {
        return @"Invalid Email";
    }
    else if([error rangeOfString:@"Password too weak!"].location != NSNotFound)
    {
        return @"Short password typed";
    }
    else
    {
        return error;
    }
}


+(NSString *)parseLoginErrorMessage:(NSString *)error
{
    if(!error)
    {
        return @"Please check your internet connection and try again.";
    }
    
    if([error rangeOfString:@"unverified"].location != NSNotFound)
    {
        return @"Your email remains unverified. Please verify your email and try again.";
    }
    else if([error rangeOfString:@"Bad username/password"].location != NSNotFound)
    {
        return @"It looks like you've entered an incorrect email address or password";
    }
    else
    {
        return error;
    }
}

+(NSString *)parseLoadingGroupErrorMessage:(NSString *)error
{
    if(!error)
    {
        return @"No network";
    }
    
    if([error rangeOfString:@"You're not allowed to do that!"].location != NSNotFound)
    {
        return @"No access";
    }
    else
    {
        return @"No network";
    }
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

#pragma mark - Videos

/**
 @param json response object. For some reason library is not returning a dictionary json object.
 For that reason we are decoding the response object manually.
 */
+ (NSNumber *)parseVideoResponse:(id)responseObject
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                      options:0
                                                        error:nil];
        
    DDLogDebug(@"Status of uploaded video: %@", json[@"status"]);
    
    return json[@"id"];
}

+ (GLPVideo *)parseVideoData:(NSDictionary *)videoData
{
    GLPVideo *video = [[GLPVideo alloc] init];
    
    NSString *status = videoData[@"status"];
    
    if([status isEqualToString:@"ready"])
    {
        DDLogInfo(@"Pending video with key: %@ ready.", videoData[@"id"]);
        
        NSArray *thumbnailArray = videoData[@"thumbnails"];
        
        [video setThumbnailUrl:thumbnailArray[0]];
        [video setUrl:videoData[@"mp4"]];
        [video setPendingKey:videoData[@"id"]];
        
        return video;
    }
    
    return nil;
}

#pragma mark - Notifications

+ (GLPNotification *)parseNotificationFromJson:(NSDictionary *)json
{
    GLPNotification *notification = [[GLPNotification alloc] init];
    NSString* notificationsType = json[@"type"];
    GLPNotificationType type;

    if([notificationsType isEqualToString:@"accepted_you"]) {
        type = kGLPNotificationTypeAcceptedYou;
    }
    else if([notificationsType isEqualToString:@"added_you"]) {
        type = kGLPNotificationTypeAddedYou;
    }
    else if([notificationsType isEqualToString:@"commented"]) {
        type = kGLPNotificationTypeCommented;
    }
    else if([notificationsType isEqualToString:@"liked"]) {
        type = kGLPNotificationTypeLiked;
    }
    else if([notificationsType isEqualToString:@"added_group"]) {
        type = kGLPNotificationTypeAddedGroup;
    }
    else if([notificationsType isEqualToString:@"group_post"])
    {
        type = kGLPNotificationTypeCreatedPostGroup;
    }
    else if([notificationsType isEqualToString:@"approved_post"])
    {
        type = kGLPNotificationTypePostApproved;
    }
    else if ([notificationsType isEqualToString:@"rejected_post"])
    {
        type = kGLPNotificationTypePostRejected;
    }
    
    notification.notificationType = type;
    notification.seen = [json[@"seen"] boolValue];
    
    notification.remoteKey = [json[@"id"] integerValue];
    notification.postRemoteKey = json[@"post"] ? [json[@"post"] integerValue] : 0;
    notification.date = [RemoteParser parseDateFromString:json[@"time"]];
    notification.user = [RemoteParser parseUserFromJson:json[@"user"]];
    
    if(json[@"network"]) {
        notification.customParams = @{@"network": json[@"network"]};
    }
    
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
    
    DDLogDebug(@"RemoteParser : parseWebSocketEventFromJson %@", json);
    
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

#pragma mark - Fourthsquare

+ (NSArray *)parseNearbyVenuesWithResponseObject:(id)responseObject
{
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                         options:0
                                                           error:nil];
    
    NSDictionary *response = json[@"response"];
    
    NSArray *venues = response[@"venues"];
    
    
    for(NSDictionary *d in venues)
    {
//        DDLogDebug(@"Name: %@", d[@"name"]);
//        
//        DDLogDebug(@"Address: %@, Lat: %@, Lgn: %@",loc[@"address"], loc[@"lat"], loc[@"lng"]);
        
        [RemoteParser insertAndSortVenueByDistanceWithJson:d andCurrentArray:locations];
    }
    
    return locations;
}

+ (void)insertAndSortVenueByDistanceWithJson:(NSDictionary *)d andCurrentArray:(NSMutableArray *)locations
{
    NSDictionary *loc = d[@"location"];
    
    GLPLocation *inLocation = [[GLPLocation alloc] initWithName:d[@"name"] address:loc[@"address"] latitude:[loc[@"lat"] doubleValue] longitude:[loc[@"lng"] doubleValue] andDistance:[loc[@"distance"] integerValue]];
    
    int index = 0;
    
    if(locations.count == 0)
    {
        [locations addObject:inLocation];
        
        return;
    }
    
    
    for (GLPLocation *location in locations) {
        
        if(inLocation.distance > location.distance)
        {
            ++index;
        }
        else
        {
            break;
        }
    }
    
    [locations insertObject:inLocation atIndex:index];
}

+ (NSArray *)parseNearbyVenuesWithResponseLocationsObject:(id)responseObject
{
    
    //Parse the responce of explore response.
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                         options:0
                                                           error:nil];
    
    NSDictionary *response = json[@"response"];
    
    NSArray *groups = response[@"groups"];
    
    NSDictionary *group = groups[0];
    
    NSArray *items = group[@"items"];
    
    for(NSDictionary *d in items)
    {
        NSDictionary *venue = d[@"venue"];
        
        
        NSDictionary *loc = venue[@"location"];

        [locations addObject:[[GLPLocation alloc] initWithName:venue[@"name"] address:loc[@"address"] latitude:[loc[@"lat"] doubleValue] longitude:[loc[@"lng"] doubleValue] andDistance:[loc[@"distance"] integerValue]]];
        

    }
    
    return locations;
}

#pragma mark - Facebook

+(BOOL)isAccountVerified:(NSDictionary *)json
{
    NSString *status = json[@"status"];
    
    if([status isEqualToString:@"unverified"])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

+(BOOL)isAccountRegistered:(NSDictionary *)json
{
    NSString *status = json[@"status"];
    
    if([status isEqualToString:@"registered"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


+(NSString *)parseFBStatusFromAPI:(NSDictionary *)json
{
    NSString *status = json[@"status"];
    
    return status;
}

+ (NSString *)parseFBRegisterErrorMessage:(NSString *)error {
    if ([error rangeOfString:@"Email required"].location != NSNotFound)
        return @"Facebook user does not have a Gleepost account assciated. Email is required.";
    else if ([error rangeOfString:@"unverified"].location != NSNotFound)
        return @"Facebook account is not verified.";
    else if ([error rangeOfString:@"Invalid email"].location != NSNotFound)
        return @"Invalid email address entered. Valid university email required.";
    else
        return @"Unknown error occured";
}


@end
