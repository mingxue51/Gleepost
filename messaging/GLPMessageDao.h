//
//  GLPMessageDao.h
//  Gleepost
//
//  Created by Lukas on 10/17/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "GLPMessage.h"
#import "GLPLiveConversation.h"


@interface GLPMessageDao : NSObject

+ (GLPMessage *)findByRemoteKey:(NSInteger)remoteKey;
+ (GLPMessage *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db;

+ (NSArray *)findLastMessagesForConversation:(GLPConversation *)conversation db:(FMDatabase *)db;
+ (NSArray *)findPreviousMessagesBefore:(GLPMessage *)message db:(FMDatabase *)db;

//+ (NSArray *)insertNewMessages:(NSArray *)newMessages andFindAllForConversation:(GLPConversation *)conversation db:(FMDatabase *)db;

+ (void)save:(GLPMessage *)entity db:(FMDatabase *)db;
//+ (void)saveOld:(GLPMessage *)entity;
+ (void)update:(GLPMessage *)entity db:(FMDatabase *)db;

//+ (void)saveNewMessageWithPossiblyNewConversation:(GLPMessage *)message db:(FMDatabase *)db;

+(GLPUser *)findUserByMessageKey:(NSInteger)messageKey db:(FMDatabase *)db;

+ (NSArray *)findLastMessagesForLiveConversation:(GLPLiveConversation *)conversation db:(FMDatabase *)db;
@end
