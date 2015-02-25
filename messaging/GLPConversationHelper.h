//
//  GLPConverationHelper.h
//  Gleepost
//
//  Created by Silouanos on 12/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPConversation;
@class GLPMessage;
@class GLPUser;

@interface GLPConversationHelper : NSObject

@property (assign, nonatomic, readonly, getter=doesBelongToGroup) BOOL belongsToGroup;

- (id)initWithBelongsToGroup:(BOOL)belongsToGroup;

- (void)resetLastShownMessageForConversation:(GLPConversation *)detachedConversation;
- (void)syncConversation:(GLPConversation *)detachedConversation;
- (NSArray *)lastestMessagesForConversation:(GLPConversation *)conversation;
- (NSArray *)oldestMessagesForConversation:(GLPConversation *)detachedConversation;
- (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey;
- (void)markConversation:(GLPConversation *)conversation upToTheLastMessageAsRead:(GLPMessage *)lastMessage;
- (NSArray *)loadLatestMessagesForConversation:(GLPConversation *)conversation;
- (void)createRegularConversationWithUsers:(NSArray *)users callback:(void (^)(GLPConversation *conversation))callback;
- (void)createRegularConversationWithUser:(GLPUser *)user callback:(void (^)(GLPConversation *conversation))callback;
- (void)syncConversationPreviousMessages:(GLPConversation *)detachedConversation;

@end
