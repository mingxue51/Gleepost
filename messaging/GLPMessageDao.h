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
+ (void)save:(GLPMessage *)entity;
+ (void)update:(GLPMessage *)entity;

@end
