//
//  GLPConversationDao.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPConversation.h"
#import "FMDatabase.h"

@interface GLPConversationDao : NSObject

+ (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db;
+ (NSArray *)findConversationsOrderByDateFilterByLive:(BOOL)liveConversations inDb:(FMDatabase *)db;
+ (void)save:(GLPConversation *)entity db:(FMDatabase *)db;
+ (void)update:(GLPConversation *)entity db:(FMDatabase *)db;
+ (void)updateConversationUnreadStatus:(GLPConversation *)entity db:(FMDatabase *)db;
+ (void)deleteAllNormalConversationsInDb:(FMDatabase *)db;

@end
