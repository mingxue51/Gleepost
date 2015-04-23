//
//  GLPPollDao.h
//  Gleepost
//
//  Created by Silouanos on 23/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPPoll;
@class FMDatabase;

@interface GLPPollDao : NSObject

+ (GLPPoll *)findPollWithPostRemoteKey:(NSInteger)postRemoteKey;
+ (GLPPoll *)findPollWithPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db;
+ (void)saveOrUpdatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey;
+ (void)saveOrUpdatePoll:(GLPPoll *)entity withPostRemoteKey:(NSInteger)postRemoteKey db:(FMDatabase *)db;

@end
