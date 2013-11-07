//
//  GLPConversationParticipantsDao.h
//  Gleepost
//
//  Created by Σιλουανός on 25/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface GLPConversationParticipantsDao : NSObject
+ (NSInteger)findByParticipantKey:(NSInteger)participantLocalKey db:(FMDatabase *)db;
+(NSInteger)findByConversationKey:(NSInteger)conversationKey db:(FMDatabase*)db;
+(NSArray*)participants:(NSInteger)conversationKey db:(FMDatabase*)db;
+ (void)deleteAll:(FMDatabase *)db;
@end
