//
//  GLPMessageDao.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "GLPMessage.h"

@interface GLPMessageDao : NSObject

+ (GLPMessage *)findByRemoteKey:(NSInteger)remoteKey;
+ (NSArray *)findLastMessagesForConversation:(GLPConversation *)conversation;
+ (GLPMessage *)findLastRemoteAndSeenForConversation:(GLPConversation *)conversation;

+ (NSArray *)insertNewMessages:(NSArray *)newMessages andFindAllForConversation:(GLPConversation *)conversation;

+ (void)save:(GLPMessage *)entity;
+ (void)saveOld:(GLPMessage *)entity;
+ (void)update:(GLPMessage *)entity;

+ (void)saveNewMessageWithPossiblyNewConversation:(GLPMessage *)message;

@end
