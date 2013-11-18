//
//  GLPLiveConversationDao.h
//  Gleepost
//
//  Created by Σιλουανός on 28/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "GLPLiveConversation.h"


@interface GLPLiveConversationDao : NSObject

+ (NSArray *)findAllOrderByDate:(FMDatabase *)db;
+ (void)update:(GLPLiveConversation *)entity db:(FMDatabase *)db;
+ (void)save:(GLPLiveConversation *)entity db:(FMDatabase *)db;
+(BOOL)deleteLiveConversationWithId:(int)conversationId db:(FMDatabase* )db;
+ (void)deleteAll:(FMDatabase *)db;
+(NSArray*)findAllOrderByExpiry:(FMDatabase*)db;
@end
