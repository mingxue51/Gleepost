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

+ (NSArray *)findAllOrderByDateForConversation:(GLPConversation *)conversation;
+ (NSArray *)findAllOrderByDateForConversation:(GLPConversation *)conversation afterInsertingNewMessages:(NSArray *)newMessages;
+ (GLPMessage *)findLastRemoteAndSeenForConversation:(GLPConversation *)conversation;

+ (void)save:(GLPMessage *)entity isNew:(BOOL)isNew;
+ (void)update:(GLPMessage *)entity;

+ (void)saveNewMessageWithPossiblyNewConversation:(GLPMessage *)message;

@end
