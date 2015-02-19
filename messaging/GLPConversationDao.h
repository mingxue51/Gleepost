//
//  GLPConversationDao.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@class FMDatabase;
@class GLPConversation;
@class GLPReadReceipt;

@interface GLPConversationDao : NSObject

+ (GLPConversation *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db;
+ (NSArray *)findMessengerConversationsOrderByDateInDb:(FMDatabase *)db;
+ (NSArray *)findGroupsConversationsOrderByDateInDb:(FMDatabase *)db;
+ (void)save:(GLPConversation *)entity db:(FMDatabase *)db;
+ (void)update:(GLPConversation *)entity db:(FMDatabase *)db;
+ (void)updateConversationLastUpdateAndLastMessage:(GLPConversation *)entity db:(FMDatabase *)db;
+ (void)updateConversationUnreadStatus:(GLPConversation *)entity db:(FMDatabase *)db;
+ (void)deleteAllNormalConversationsInDb:(FMDatabase *)db;
+ (void)deleteConversationWithRemoteKey:(NSInteger)conversationRemoteKey db:(FMDatabase *)db;
+ (void)saveIfNotExist:(GLPConversation *)entity db:(FMDatabase *)db;
+ (void)saveReadReceiptIfNotExist:(GLPReadReceipt *)readReceipt db:(FMDatabase *)db;
+(GLPConversation *)findByParticipantKey:(int)key db:(FMDatabase *)db;
+ (NSArray *)findReadsWithConversation:(GLPConversation *)entity andDb:(FMDatabase *)db;

@end
