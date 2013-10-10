//
//  WebClient.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "User.h"
#import "Post.h"
#import "Comment.h"
#import "Topic.h"
#import "Conversation.h"
#import "RemoteConversation.h"

@interface WebClient : AFHTTPClient

+ (WebClient *)sharedInstance;

- (void)loginWithName:(NSString *)name password:(NSString *)password andCallbackBlock:(void (^)(BOOL success))callbackBlock;
- (void)registerWithName:(NSString *)name email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getPostsWithCallbackBlock:(void (^)(BOOL success, NSArray *posts))callbackBlock;
- (void)createPost:(Post *)post callbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getCommentsForPost:(Post *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock;
- (void)createComment:(Comment *)comment callbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock;

- (void)getMessagesForConversation:(Conversation *)conversation withCallbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;
- (void)getLastMessagesForConversation:(RemoteConversation *)conversation withLastMessage:(RemoteMessage *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;

- (void)longPollNewMessagesWithCallbackBlock:(void (^)(BOOL success, Message *conversation))callbackBlock;
- (void)cancelMessagesLongPolling;
- (void)createMessage:(RemoteMessage *)message callbackBlock:(void (^)(BOOL success))callbackBlock;
- (void)createMessageSynchronously:(RemoteMessage *)message callbackBlock:(void (^)(BOOL success, NSInteger remoteKey))callbackBlock;

- (void)createOneToOneConversationWithCallbackBlock:(void (^)(BOOL success, Conversation *conversation))callbackBlock;
- (void)createGroupConversationWithCallbackBlock:(void (^)(BOOL success, Conversation *conversation))callbackBlock;




@end
