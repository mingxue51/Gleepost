//
//  JsonParser.h
//  messaging
//
//  Created by Lukas on 8/28/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserNetwork.h"
#import "Post.h"
#import "Comment.h"
#import "OldConversation.h"
#import "OldMessage.h"

@interface JsonParser : NSObject

//+ (OldUser *)parseUserFromJson:(NSDictionary *)json;
+ (UserNetwork *)parseUserNetworkFromJson:(NSDictionary *)json;
+ (Post *)parsePostFromJson:(NSDictionary *)json;
+ (NSArray *)parsePostsFromJson:(NSDictionary *)json;
+ (Comment *)parseCommentFromJson:(NSDictionary *)json;
+ (NSArray *)parseCommentsFromJson:(NSArray *)jsonComments;

+ (OldConversation *)parseConversationFromJson:(NSDictionary *)json ignoringUserKey:(NSInteger)userKeyToIgnore;
+ (NSArray *)parseConversationsFromJson:(NSArray *)jsonConversations ignoringUserKey:(NSInteger)userKeyToIgnore;
+ (OldMessage *)parseMessageFromJson:(NSDictionary *)json;
+ (NSArray *)parseMessagesFromJson:(NSArray *)jsonMessages;
    
@end
