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

+ (GLPMessage *)findByRemoteKey:(NSInteger)remoteKey db:(FMDatabase *)db;

+ (NSArray *)findLastMessagesForConversation:(GLPConversation *)conversation db:(FMDatabase *)db;
+ (NSArray *)findPreviousMessagesBefore:(GLPMessage *)message db:(FMDatabase *)db;

+ (void)save:(GLPMessage *)entity db:(FMDatabase *)db;
+ (void)updateAfterSending:(GLPMessage *)entity db:(FMDatabase *)db;


// todo: remove
+(GLPUser *)findUserByMessageKey:(NSInteger)messageKey db:(FMDatabase *)db;

@end
