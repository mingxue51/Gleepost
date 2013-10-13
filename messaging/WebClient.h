//
//  WebClient.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "OldUser.h"
#import "Post.h"
#import "Comment.h"
#import "Topic.h"
#import "Conversation.h"
#import "Message.h"

@interface WebClient : AFHTTPClient

+ (WebClient *)sharedInstance;

- (void)loginWithName:(NSString *)name password:(NSString *)password andCallbackBlock:(void (^)(BOOL success))callbackBlock;
- (void)registerWithName:(NSString *)name email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getPostsWithCallbackBlock:(void (^)(BOOL success, NSArray *posts))callbackBlock;
- (void)createPost:(Post *)post callbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getCommentsForPost:(Post *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock;
- (void)createComment:(Comment *)comment callbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock;

- (void)getLastMessagesForConversation:(Conversation *)conversation withLastMessage:(Message *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;

- (void)longPollNewMessagesForConversation:(Conversation *)conversation callbackBlock:(void (^)(BOOL success, Message *message))callbackBlock;
- (void)cancelMessagesLongPolling;
- (void)createMessage:(Message *)message callbackBlock:(void (^)(BOOL success, NSInteger remoteKey))callbackBlock;
- (void)createMessageSynchronously:(Message *)message callbackBlock:(void (^)(BOOL success, NSInteger remoteKey))callbackBlock;

- (void)createOneToOneConversationWithCallbackBlock:(void (^)(BOOL success, Conversation *conversation))callbackBlock;
- (void)createGroupConversationWithCallbackBlock:(void (^)(BOOL success, Conversation *conversation))callbackBlock;




@end
