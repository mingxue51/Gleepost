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

+ (void)save:(GLPLiveConversation *)entity db:(FMDatabase *)db;
+ (NSArray *)findAllOrderByDate:(FMDatabase *)db;
+ (void)update:(GLPLiveConversation *)entity db:(FMDatabase *)db;

@end
