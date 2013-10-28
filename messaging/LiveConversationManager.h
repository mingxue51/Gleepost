//
//  LiveConversationManager.h
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPLiveConversationDao.h"

@interface LiveConversationManager : NSObject

+ (NSArray *)getLocalConversations;
+ (void)loadConversationsWithLocalCallback:(void (^)(NSArray *conversations))localCallback remoteCallback:(void (^)(BOOL success, NSArray *conversations))remoteCallback;
+(void) addLiveConversation:(GLPLiveConversation*)newConversation;
+ (void)loadMessagesForLiveConversation:(GLPLiveConversation *)conversation localCallback:(void (^)(NSArray *messages))localCallback remoteCallback:(void (^)(BOOL success, NSArray *messages))remoteCallback;
+ (GLPMessage *)createMessageWithContent:(NSString *)content toLiveConversation:(GLPLiveConversation *)conversation sendCallback:(void (^)(GLPMessage *sentMessage, BOOL success))sendCallback;
@end
