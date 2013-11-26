//
//  WebClient.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "GLPPost.h"
#import "GLPComment.h"
#import "GLPConversation.h"
#import "GLPMessage.h"
#import "GLPLiveConversation.h"
#import "GLPNotification.h"

@interface WebClient : AFHTTPClient

@property (assign, nonatomic) BOOL isNetworkAvailable;

+ (WebClient *)sharedInstance;

- (void)activate;

- (void)loginWithName:(NSString *)name password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, GLPUser *user, NSString *token, NSDate *expirationDate))callbackBlock;
- (void)registerWithName:(NSString *)name email:(NSString *)email password:(NSString *)password andCallbackBlock:(void (^)(BOOL success, NSString* responseObject, int userRemoteKey))callbackBlock;
- (void)registerPushToken:(NSString *)pushToken callback:(void (^)(BOOL success))callback;

- (void)getPostsAfter:(GLPPost *)post callback:(void (^)(BOOL success, NSArray *posts))callbackBlock;
- (void)createPost:(GLPPost *)post callbackBlock:(void (^)(BOOL success, int remoteKey))callbackBlock;
-(void)getPostWithRemoteKey:(int)remoteKey withCallbackBlock:(void (^) (BOOL success, GLPPost *post))callbackBlock;

- (void)getCommentsForPost:(GLPPost *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock;
- (void)createComment:(GLPComment *)comment callbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getConversationsFilterByLive:(BOOL)live withCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock;
- (void)getLiveConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock;


- (void)getLastMessagesForConversation:(GLPConversation *)conversation withLastMessage:(GLPMessage *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;
- (void)getPreviousMessagesBefore:(GLPMessage *)message callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;

- (void)synchronousLongPollWithCallback:(void (^)(BOOL success, GLPMessage *message))callback;


- (void)createMessage:(GLPMessage *)message callbackBlock:(void (^)(BOOL success, NSInteger remoteKey))callbackBlock;
- (void)createMessageSynchronously:(GLPMessage *)message callbackBlock:(void (^)(BOOL success, NSInteger remoteKey))callbackBlock;

- (void)createOneToOneConversationWithCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock;
- (void)createGroupConversationWithCallbackBlock:(void (^)(BOOL success, GLPConversation *conversation))callbackBlock;

- (void)getUserWithKey:(NSInteger)key callbackBlock:(void (^)(BOOL success, GLPUser *user))callbackBlock;
-(void) getContactsWithCallbackBlock:(void (^)(BOOL success, NSArray *contacts))callbackBlock;
-(void)acceptContact:(int)contactRemoteKey callbackBlock:(void (^)(BOOL success))callbackBlock;

-(void)setBusyStatus:(BOOL)busy callbackBlock:(void (^)(BOOL success))callbackBlock;
-(void)getBusyStatus:(void (^) (BOOL success, BOOL status))callbackBlock;

-(void)addContact:(int)contactRemoteKey callbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getLastMessagesForLiveConversation:(GLPLiveConversation *)conversation withLastMessage:(GLPMessage *)lastMessage callbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock;

-(void)uploadImage:(NSData*)image ForUserRemoteKey:(int)userRemoteKey callbackBlock: (void (^)(BOOL success, NSString *response)) callbackBlock;
-(void)uploadImage:(NSData *)imageData callback:(void (^)(BOOL success, NSString *imageUrl))callback;

-(void)uploadImageToProfileUser:(NSString *)url callbackBlock:(void (^)(BOOL))callbackBlock;

-(void)postLike:(BOOL)like forPostRemoteKey:(int)postRemoteKey callbackBlock:(void (^) (BOOL success))callbackBlock;

// notifications
-(void)synchronousGetNotificationsWithCallback:(void (^)(BOOL success, NSArray *notifications))callback;
- (void)markNotificationRead:(GLPNotification *)notification callback:(void (^)(BOOL success, NSArray *notifications))callback;

@end
